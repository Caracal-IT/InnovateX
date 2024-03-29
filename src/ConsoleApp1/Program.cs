// See https://aka.ms/new-console-template for more information

using System.Text;
using MQTTnet;
using MQTTnet.Client;
using MQTTnet.Extensions.ManagedClient;
using MQTTnet.Formatter;
using MQTTnet.Protocol;

var mqttClient = new MqttClient();
await mqttClient.ConnectAsync();

var cancellationTokenSource = new CancellationTokenSource(TimeSpan.FromSeconds(10));

try
{
    for (int i = 0; i < 20; i++)
    {
        var action = new MqttAction("elm/test", $"Ettiene {Random.Shared.Next(10, 99)}", "elm/response");
        var result = await MqttActionWrapper.ExecuteAsync(action, mqttClient, cancellationTokenSource.Token);
        Console.WriteLine(result);
    }
}
catch (Exception e)
{
    Console.WriteLine(e);
}
finally
{
    await mqttClient.DisconnectAsync();
}
Console.WriteLine("Done");

public record struct MqttCommand(string Topic, string? Payload, Guid? CorrelationId = default);

public record struct MqttAction(string Topic, string Payload, string ResponseTopic);

public class MqttActionWrapper
{
    private readonly Guid _correlationId;
    private readonly TaskCompletionSource<string> _tcs = new ();

    private MqttActionWrapper(MqttClient client)
    {
        _correlationId = Guid.NewGuid();
        client.ApplicationMessageReceivedAsync += OnApplicationMessageReceivedAsync;
    }

    public static async Task<string> ExecuteAsync(MqttAction action, MqttClient client, CancellationToken token)
    {
        var a = action with { ResponseTopic = $"{action.ResponseTopic}@{Guid.NewGuid()}" };
        var wrapper = new MqttActionWrapper(client);
        await client.SubscribeAsync(a.ResponseTopic);
        await client.SubscribeAsync($"{Settings.ErrorTopic}/{wrapper._correlationId}");
        await client.EnqueueAsync(new MqttCommand(action.Topic, action.Payload, wrapper._correlationId), a.ResponseTopic);
        var rsp = await wrapper.WaitAsync(token);
        await client.UnsubscribeAsync(a.ResponseTopic);
        await client.UnsubscribeAsync($"{Settings.ErrorTopic}/{wrapper._correlationId}");
        await client.EnqueueAsync(new MqttCommand(a.ResponseTopic, null));
        
        return rsp;
    }
    
    private Task<string> WaitAsync(CancellationToken token)
    {
        token.Register(() => _tcs.TrySetCanceled());
        return _tcs.Task;
    }

    private Task OnApplicationMessageReceivedAsync(MqttApplicationMessageReceivedEventArgs arg)
    {
        if(arg.ApplicationMessage.CorrelationData.SequenceEqual(_correlationId.ToByteArray()))
        {
            _tcs.TrySetResult(Encoding.UTF8.GetString(arg.ApplicationMessage.PayloadSegment));
        }
        
        return Task.CompletedTask;
    }
}

public class MqttClient
{
    private readonly IManagedMqttClient _mqttClient = new MqttFactory().CreateManagedMqttClient();
    
    public event Func<MqttApplicationMessageReceivedEventArgs, Task>? ApplicationMessageReceivedAsync;

    public MqttClient() => 
        _mqttClient.ApplicationMessageReceivedAsync += MqttClientOnApplicationMessageReceivedAsync;

    private async Task MqttClientOnApplicationMessageReceivedAsync(MqttApplicationMessageReceivedEventArgs arg)
    {
            if (arg.ApplicationMessage.ResponseTopic != null)
            {
                var payload = string.Empty;
                
                if (arg.ApplicationMessage.PayloadSegment.Array != null)
                    payload = Encoding.UTF8.GetString(arg.ApplicationMessage.PayloadSegment.Array);
                
                var msg = Random.Shared.Next(0, 99) % 5 == 0 ? GetErrorMessage(payload)  : GetResponseMessage(payload);

                await _mqttClient.EnqueueAsync(msg);
                return;
            }

            if (ApplicationMessageReceivedAsync != null) await ApplicationMessageReceivedAsync(arg);
            return;

            MqttApplicationMessage GetResponseMessage(string payload)
            {
                return new MqttApplicationMessageBuilder()
                    .WithTopic(arg.ApplicationMessage.ResponseTopic)
                    .WithPayload($"Hello {Random.Shared.Next(10, 99)} {payload}")
                    .WithCorrelationData(arg.ApplicationMessage.CorrelationData)
                    .WithQualityOfServiceLevel(MqttQualityOfServiceLevel.AtLeastOnce)
                    .WithRetainFlag()
                    .WithMessageExpiryInterval(60)
                    .Build();
            }
            
            MqttApplicationMessage GetErrorMessage(string payload)
            {
                return new MqttApplicationMessageBuilder()
                    .WithTopic($"{Settings.ErrorTopic}/{new Guid(arg.ApplicationMessage.CorrelationData)}")
                    .WithPayload($"Error: Hello {Random.Shared.Next(10, 99)} {payload}")
                    .WithCorrelationData(arg.ApplicationMessage.CorrelationData)
                    .WithQualityOfServiceLevel(MqttQualityOfServiceLevel.AtLeastOnce)
                    .WithRetainFlag()
                    .WithMessageExpiryInterval(60)
                    .Build();
            }
    }

    public async Task ConnectAsync()
    {
         var options = new ManagedMqttClientOptionsBuilder()
            .WithAutoReconnectDelay(TimeSpan.FromSeconds(5))
            .WithClientOptions(new MqttClientOptionsBuilder()
                .WithClientId("Client1")
                .WithTcpServer(Settings.MqttServer, Settings.MqttPort)
                .WithProtocolVersion(MqttProtocolVersion.V500)
                .WithCleanSession()
                .Build())
            .Build();

         await _mqttClient.StartAsync(options).ConfigureAwait(false);
    }
    
    public async Task DisconnectAsync() => await _mqttClient.StopAsync().ConfigureAwait(false);

    public Task SubscribeAsync(string topic) => _mqttClient.SubscribeAsync(topic);
    public Task UnsubscribeAsync(string topic) => _mqttClient.UnsubscribeAsync(topic);

    public async Task EnqueueAsync(MqttCommand command, string? responseTopic = default)
    {
        var message = new MqttApplicationMessageBuilder()
            .WithTopic(command.Topic)
            .WithPayload(command.Payload)
            .WithQualityOfServiceLevel(MqttQualityOfServiceLevel.AtLeastOnce)
            .WithMessageExpiryInterval(Settings.Timeout)
            .WithRetainFlag();

        if (responseTopic is not null)
            message = message.WithResponseTopic(responseTopic);

        var message2 = message.WithCorrelationData((command.CorrelationId ?? Guid.NewGuid()).ToByteArray()).Build();

        await SubscribeAsync(command.Topic).ConfigureAwait(false);
        await _mqttClient.EnqueueAsync(message2).ConfigureAwait(false);
    }
}

public static class Settings
{
    public static string MqttServer => "dev.caracal.com";
    public static int MqttPort => 1883;
    public static uint Timeout => 60;
    public static string ErrorTopic => "errors/action";
}