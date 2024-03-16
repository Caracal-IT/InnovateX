// See https://aka.ms/new-console-template for more information

using System.Text;
using MQTTnet;
using MQTTnet.Client;
using MQTTnet.Extensions.ManagedClient;
using MQTTnet.Formatter;
using MQTTnet.Protocol;

Console.WriteLine("Hello, World!");

var mqttClient = new MqttClient();
await mqttClient.ConnectAsync();

var cancellationTokenSource = new CancellationTokenSource(TimeSpan.FromSeconds(5));

var result = "";

try
{
    var action = new MqttAction("elm/test", "Ettiene", "elm/response");
    result = await MqttActionWrapper.ExecuteAsync(action, mqttClient, cancellationTokenSource.Token);
}
catch (Exception e)
{
    Console.WriteLine(e);
}
finally
{
    await mqttClient.DisconnectAsync();
}

Console.WriteLine(result);
Console.WriteLine("Done");

public record struct MqttCommand(string Topic, string Payload, Guid? CorrelationId = default);

public record struct MqttAction(string Topic, string Payload, string ResponseTopic);

public class MqttActionWrapper
{
    private readonly MqttClient _client;
    public MqttAction Action { get; set; }
    public TaskCompletionSource<string> TaskCompletionSource { get; set; }
    public Guid CorrelationId { get; set; }
    private TaskCompletionSource<string> _tcs = new ();

    private MqttActionWrapper(MqttAction action, MqttClient client)
    {
        _client = client;
        Action = action;
        TaskCompletionSource = new TaskCompletionSource<string>();
        CorrelationId = Guid.NewGuid();
        client.ApplicationMessageReceivedAsync += OnApplicationMessageReceivedAsync;
    }

    public static async Task<string> ExecuteAsync(MqttAction action, MqttClient client, CancellationToken token)
    {
        var wrapper = new MqttActionWrapper(action, client);
        await client.SubscribeAsync(action.ResponseTopic);
        await client.EnqueueAsync(new MqttCommand(action.Topic, action.Payload, wrapper.CorrelationId), action.ResponseTopic);
        return await wrapper.WaitAsync(token);
    }
    
    private Task<string> WaitAsync(CancellationToken token)
    {
        token.Register(() => _tcs.TrySetCanceled());
        return _tcs.Task;
    }

    private Task OnApplicationMessageReceivedAsync(MqttApplicationMessageReceivedEventArgs arg)
    {
        if(arg.ApplicationMessage.Topic == Action.ResponseTopic && arg.ApplicationMessage.CorrelationData.SequenceEqual(CorrelationId.ToByteArray()))
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

    public MqttClient()
    {
        _mqttClient.ApplicationMessageReceivedAsync += MqttClientOnApplicationMessageReceivedAsync;
    }

    private async Task MqttClientOnApplicationMessageReceivedAsync(MqttApplicationMessageReceivedEventArgs arg)
    {
            if (arg.ApplicationMessage.ResponseTopic != null)
            {
                var response = new MqttApplicationMessageBuilder()
                    .WithTopic(arg.ApplicationMessage.ResponseTopic)
                    .WithPayload("Hello")
                    .WithCorrelationData(arg.ApplicationMessage.CorrelationData)
                    .WithQualityOfServiceLevel(MqttQualityOfServiceLevel.AtLeastOnce)
                    .WithRetainFlag()
                    .Build();
                
                await _mqttClient.EnqueueAsync(response);
                return;
            }

            if (ApplicationMessageReceivedAsync != null) await ApplicationMessageReceivedAsync(arg);
    }

    public async Task ConnectAsync()
    {
         var options = new ManagedMqttClientOptionsBuilder()
            .WithAutoReconnectDelay(TimeSpan.FromSeconds(5))
            .WithClientOptions(new MqttClientOptionsBuilder()
                .WithClientId("Client1")
                .WithTcpServer("dev.caracal.com", 1883)
                .WithProtocolVersion(MqttProtocolVersion.V500)
                //.WithCredentials("bud", "%spencer%")
                .WithCleanSession()
                .Build())
            .Build();

         await _mqttClient.StartAsync(options).ConfigureAwait(false);
    }
    
    public async Task DisconnectAsync() => await _mqttClient.StopAsync().ConfigureAwait(false);

    public Task SubscribeAsync(string topic) => _mqttClient.SubscribeAsync(topic);

    public async Task EnqueueAsync(MqttCommand command, string? responseTopic = default)
    {
        var message = new MqttApplicationMessageBuilder()
            .WithTopic(command.Topic)
            .WithPayload(command.Payload)
            .WithQualityOfServiceLevel(MqttQualityOfServiceLevel.AtLeastOnce)
            .WithRetainFlag();
            
            if(responseTopic is not null)
                message = message.WithResponseTopic(responseTopic);
                    
            var message2 = message.WithCorrelationData((command.CorrelationId??Guid.NewGuid()).ToByteArray())
            .Build();

            await SubscribeAsync(command.Topic).ConfigureAwait(false);

        await _mqttClient.EnqueueAsync(message2).ConfigureAwait(false);
    }
}