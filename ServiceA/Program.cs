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
    return new { Service = "ServiceA", Forecast = forecast };
})
.WithName("GetWeatherFromA")
.WithOpenApi();

app.MapGet("/api/hello", () => new { Service = "ServiceA", Message = "Hello from Service A!", Time = DateTime.Now })
.WithName("GetHelloFromA")
.WithOpenApi();

app.MapGet("/api/info", () => new
{
    Service = "ServiceA",
    Version = "1.0.0",
    Port = 5001,
    Status = "Healthy",
    Timestamp = DateTime.Now
})
.WithName("GetInfoFromA")
.WithOpenApi();

app.MapPost("/api/data", (DataRequest request) => new
{
    Service = "ServiceA",
    Received = request,
    ProcessedAt = DateTime.Now,
    Status = "Processed"
})
.WithName("PostDataToA")
.WithOpenApi();

app.MapGet("/api/users/{id}", (int id) => new
{
    Service = "ServiceA",
    UserId = id,
    Name = $"User {id} from Service A",
    Email = $"user{id}@servicea.com"
})
.WithName("GetUserFromA")
.WithOpenApi();

app.Run();

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}

record DataRequest(string Name, string Value);
