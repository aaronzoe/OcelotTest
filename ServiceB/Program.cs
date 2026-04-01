var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapGet("/api/hello", () => new { Service = "ServiceB", Message = "Hello from Service B!", Time = DateTime.Now })
.WithName("GetHelloFromB")
.WithOpenApi();

app.MapGet("/api/info", () => new
{
    Service = "ServiceB",
    Version = "1.0.0",
    Port = 5002,
    Status = "Healthy",
    Timestamp = DateTime.Now
})
.WithName("GetInfoFromB")
.WithOpenApi();

app.MapPost("/api/data", (DataRequest request) => new
{
    Service = "ServiceB",
    Received = request,
    ProcessedAt = DateTime.Now,
    Status = "Processed"
})
.WithName("PostDataToB")
.WithOpenApi();

app.MapGet("/api/products/{id}", (int id) => new
{
    Service = "ServiceB",
    ProductId = id,
    Name = $"Product {id} from Service B",
    Price = Random.Shared.Next(100, 1000)
})
.WithName("GetProductFromB")
.WithOpenApi();

app.MapGet("/api/orders", () => new
{
    Service = "ServiceB",
    Orders = new[]
    {
        new { OrderId = 1, Product = "Laptop", Quantity = 1 },
        new { OrderId = 2, Product = "Mouse", Quantity = 2 },
        new { OrderId = 3, Product = "Keyboard", Quantity = 1 }
    },
    Total = 3,
    Timestamp = DateTime.Now
})
.WithName("GetOrdersFromB")
.WithOpenApi();

app.Run();

record DataRequest(string Name, string Value);
