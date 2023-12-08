using System.Configuration;
using Dapr.Client;
using Microsoft.ApplicationInsights.Extensibility;

var builder = WebApplication.CreateBuilder(args);



// Add services to the container.
builder.Services.AddControllersWithViews();
//builder.Services.AddHttpClient("ToDoAPI", client => {
//    client.BaseAddress = new Uri(builder.Configuration["ToDoAPIUrl"]);
//});

builder.Services.AddSingleton<DaprClient>(_ => new DaprClientBuilder().Build());

builder.Services.AddApplicationInsightsTelemetry();
 
builder.Services.Configure<TelemetryConfiguration>((o) => {
    o.TelemetryInitializers.Add(new AppInsightsTelemetryInitializer());
});


var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
}
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=ToDoItem}/{action=Index}/{id?}");

// app.Run("http://localhost:8080");
app.Run();
