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
        private readonly IToDoItemCosmosDbService _cosmosDbService;
        public ToDoItemController(IToDoItemCosmosDbService cosmosDbService)
        {
            _cosmosDbService = cosmosDbService;
        }

        [HttpGet]
        public async Task<IEnumerable<ToDoItem>> Get()
        {
            return await _cosmosDbService.GetItemsAsync("SELECT * FROM c");
        }

        [HttpGet("{id}")]
        public async Task<ToDoItem> Get(string id)
        {
            ToDoItem toDoItem = await _cosmosDbService.GetItemAsync(id);
            return toDoItem;
        }

        [HttpPost]
        public async Task Post(ToDoItem item)
        {
            await _cosmosDbService.AddItemAsync(item);
        }

        [HttpPut(("{id}"))]
        public async Task Put(String id,ToDoItem item)
        {
            await _cosmosDbService.UpdateItemAsync(id,item);
        }

        [HttpDelete("{id}")]
        public async Task Delete(String id)
        {
            await _cosmosDbService.DeleteItemAsync(id);
        }

    }
}
