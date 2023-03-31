using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using todo.Services;
using ToDoWebApp.API.Models;

namespace ToDoWebApp.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ToDoItemController : Controller
    {
        private readonly ILogger<ToDoItemController> _logger;
        private readonly IToDoItemCosmosDbService _cosmosDbService;
        public ToDoItemController(ILogger<ToDoItemController> logger, IToDoItemCosmosDbService cosmosDbService)
        {
            _cosmosDbService = cosmosDbService;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IEnumerable<ToDoItem>> Get()
        {
            _logger.LogInformation("Getting all items");
            return await _cosmosDbService.GetItemsAsync("SELECT * FROM c");
        }

        [HttpGet("{id}")]
        public async Task<ToDoItem> Get(string id)
        {
            _logger.LogInformation("Getting item with id: {0}", id);
            ToDoItem toDoItem = await _cosmosDbService.GetItemAsync(id);
            return toDoItem;
        }

        [HttpPost]
        public async Task Post(ToDoItem item)
        {
            _logger.LogInformation("Adding item with id: {0}", item.Id);
            await _cosmosDbService.AddItemAsync(item);
        }

        [HttpPut(("{id}"))]
        public async Task Put(String id,ToDoItem item)
        {
            _logger.LogInformation("Updating item with id: {0}", id);
            await _cosmosDbService.UpdateItemAsync(id,item);
        }

        [HttpDelete("{id}")]
        public async Task Delete(String id)
        {
            _logger.LogInformation("Deleting item with id: {0}", id);
            await _cosmosDbService.DeleteItemAsync(id);
        }

    }
}
