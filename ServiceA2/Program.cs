var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/api/weather", () =>
{
    var forecast = Enumerable.Range(1, 5).Select(index =>
        new WeatherForecast
        (
            DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            Random.Shared.Next(-20, 55),
            summaries[Random.Shared.Next(summaries.Length)]
        ))
        .ToArray();
    return new { Service = "ServiceA2", Forecast = forecast };
})
.WithName("GetWeatherFromA2")
.WithOpenApi();

app.MapGet("/api/hello", () => new { Service = "ServiceA2", Message = "Hello from Service A2!", Time = DateTime.Now })
.WithName("GetHelloFromA2")
.WithOpenApi();

app.MapGet("/api/info", () => new
{
    Service = "ServiceA2",
    Version = "1.0.0",
    Port = 5003,
    Status = "Healthy",
    Timestamp = DateTime.Now
})
.WithName("GetInfoFromA2")
.WithOpenApi();

app.MapPost("/api/data", (DataRequest request) => new
{
    Service = "ServiceA2",
    Received = request,
    ProcessedAt = DateTime.Now,
    Status = "Processed"
})
.WithName("PostDataToA2")
.WithOpenApi();

app.MapGet("/api/users/{id}", (int id) => new
{
    Service = "ServiceA2",
    UserId = id,
    Name = $"User {id} from Service A2",
    Email = $"user{id}@servicea2.com"
})
.WithName("GetUserFromA2")
.WithOpenApi();

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}

record DataRequest(string Name, string Value);
