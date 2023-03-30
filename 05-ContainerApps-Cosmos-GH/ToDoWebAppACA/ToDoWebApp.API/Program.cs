using todo.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddSingleton<IToDoItemCosmosDbService>(InitializeCosmosClientInstanceAsync(builder.Configuration).GetAwaiter().GetResult());

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();

app.MapControllers();

app.Run();

static async Task<IToDoItemCosmosDbService> InitializeCosmosClientInstanceAsync(Microsoft.Extensions.Configuration.ConfigurationManager configuration)
{
    var configurationSection = configuration.GetSection("CosmosDb");
    string databaseName = configurationSection.GetSection("DatabaseName").Value;
    string containerName = configurationSection.GetSection("ContainerName").Value;
    string databaseConnectionString = configuration["ConnectionString"];
    var client = new Microsoft.Azure.Cosmos.CosmosClient(databaseConnectionString);
    IToDoItemCosmosDbService cosmosDbService = new ToDoItemCosmosDbService(client, databaseName, containerName);
    Microsoft.Azure.Cosmos.DatabaseResponse database = await client.CreateDatabaseIfNotExistsAsync(databaseName);
    await database.Database.CreateContainerIfNotExistsAsync(containerName, "/id");

    return cosmosDbService;
}