using Dapr.Client;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Cryptography.X509Certificates;
using System.Threading.Tasks;
//using todo.Services;
using ToDoWebApp.API.Models;

namespace ToDoWebApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ToDoItemController : Controller
    {
        const string STORE_NAME = "todostatestore";

        private readonly ILogger<ToDoItemController> _logger;
        private readonly DaprClient _daprClient;
        //private readonly IToDoItemDbService _cosmosDbService;
        //public ToDoItemController(ILogger<ToDoItemController> logger, IToDoItemDbService cosmosDbService, DaprClient daprClient)
        public ToDoItemController(ILogger<ToDoItemController> logger, DaprClient daprClient)
        {
            //_cosmosDbService = cosmosDbService;
            _logger = logger;
            _daprClient = daprClient;
        }

        [HttpGet]
        public async Task<IEnumerable<ToDoItem>> Get()
        {
            _logger.LogInformation("Getting all items");
            Dictionary<string, string> metadata = new() { { "contentType", "application/json" } };
            var query = "{" +
                "\"filter\": {" +
                "}" +
            "}";
            var todoItems = await _daprClient.QueryStateAsync<ToDoItem>(STORE_NAME, query,metadata: metadata);
            return todoItems.Results.Select(q => q.Data).ToList();
        }

        [HttpGet("{id}")]
        public async Task<ToDoItem?> Get(string id)
        {
            _logger.LogInformation("Getting item with id: {0}", id);
            //ToDoItem toDoItem = await _cosmosDbService.GetItemAsync(id);
            var todoItem = await _daprClient.GetStateAsync<ToDoItem>(STORE_NAME, id);
            return todoItem;
        }

        [HttpPost]
        public async Task Post(ToDoItem item)
        {
            _logger.LogInformation("Adding item with id: {0}", item.Id);
            //await _cosmosDbService.AddItemAsync(item);
            await _daprClient.SaveStateAsync<ToDoItem>(STORE_NAME, item.Id, item);
        }

        [HttpPut(("{id}"))]
        public async Task Put(String id,ToDoItem item)
        {
            _logger.LogInformation("Updating item with id: {0}", id);
            //await _cosmosDbService.UpdateItemAsync(id,item);
            await _daprClient.SaveStateAsync<ToDoItem>(STORE_NAME, item.Id, item);
        }

        [HttpDelete("{id}")]
        public async Task Delete(String id)
        {
            _logger.LogInformation("Deleting item with id: {0}", id);
            //await _cosmosDbService.DeleteItemAsync(id);
            await _daprClient.DeleteStateAsync(STORE_NAME, id);
        }

    }
}
