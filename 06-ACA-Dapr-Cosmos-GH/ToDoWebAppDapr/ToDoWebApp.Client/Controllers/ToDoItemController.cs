namespace ToDoWebApp.Client.Controllers
{
    using System;
    using System.Net.Http;
    using System.Threading.Tasks;
    using Dapr.Client;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Logging;
    using Newtonsoft.Json;
    using NuGet.Protocol.Plugins;
    using ToDoWebApp.Client.Models;

    public class ToDoItemController : Controller
    {
        private readonly ILogger<ToDoItemController> _logger;
        // private readonly HttpClient _httpClient;
        private readonly DaprClient _daprClient;
        // public ToDoItemController(ILogger<ToDoItemController> logger, IHttpClientFactory httpClientFactory,  DaprClient daprClient)
        public ToDoItemController(ILogger<ToDoItemController> logger,  DaprClient daprClient)
        {
            _logger = logger;
            // _httpClient = httpClientFactory.CreateClient("ToDoAPI");
            _daprClient = daprClient;
        }

        [ActionName("Index")]
        public async Task<IActionResult> Index()
        {
            // var response = await _httpClient.GetAsync("api/todoitem");
            // var content = await response.Content.ReadAsStringAsync();
            // var items = JsonConvert.DeserializeObject<IEnumerable<ToDoItem>>(content);

            var items = await _daprClient.InvokeMethodAsync<List<ToDoItem>>(HttpMethod.Get, "dapr-api", $"api/todoitem");
            return View(items);
        }

        [ActionName("Create")]
        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        [ActionName("Create")]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> CreateAsync([Bind("Id,Name,Description,Completed")] ToDoItem item)
        {
            if (ModelState.IsValid)
            {
                item.Id = Guid.NewGuid().ToString();
                _logger.LogInformation("Adding item with id: {0}", item.Id);
                // await _httpClient.PostAsJsonAsync("api/todoitem", item);
                await _daprClient.InvokeMethodAsync<ToDoItem>(HttpMethod.Post, "dapr-api", "api/todoitem", item);
                _logger.LogInformation("Added item with id: {0}", item.Id);
                return RedirectToAction("Index");
            }
            else
            {
                foreach (var error in ModelState.Values.SelectMany(v => v.Errors))
                {
                    _logger.LogError(error.ToString());
                }
            }

            return View(item);
        }

        [HttpPost]
        [ActionName("Edit")]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> EditAsync([Bind("Id,Name,Description,Completed")] ToDoItem item)
        {
            if (ModelState.IsValid)
            {
                // await _httpClient.PutAsJsonAsync("api/todoitem/"+ item.Id, item);
                await _daprClient.InvokeMethodAsync<ToDoItem>(HttpMethod.Put, "dapr-api", $"api/todoitem/{item.Id}", item);
            }

            return View(item);
        }

        [ActionName("Edit")]
        public async Task<ActionResult> EditAsync(string id)
        {
            if (id == null)
            {
                return BadRequest();
            }

            // var response = await _httpClient.GetAsync("api/todoitem/"+ id);
            // var content = await response.Content.ReadAsStringAsync();
            // var item = JsonConvert.DeserializeObject<ToDoItem>(content);
            var item = await _daprClient.InvokeMethodAsync<ToDoItem>(HttpMethod.Get, "dapr-api", $"api/tasks/{id}");

            if (item == null)
            {
                return NotFound();
            }

            return View(item);
        }

        [ActionName("Delete")]
        public async Task<ActionResult> DeleteAsync(string id)
        {
            if (id == null)
            {
                return BadRequest();
            }

            // var response = await _httpClient.GetAsync("api/todoitem/" + id);
            // var content = await response.Content.ReadAsStringAsync();
            // var item = JsonConvert.DeserializeObject<ToDoItem>(content);

            var item = await _daprClient.InvokeMethodAsync<ToDoItem>(HttpMethod.Get, "dapr-api", $"api/todoitem/{id}");

            if (item == null)
            {
                return NotFound();
            }

            return View(item);
        }

        [HttpPost]
        [ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> DeleteConfirmedAsync([Bind("Id")] string id)
        {
            // await _httpClient.DeleteAsync("api/todoitem/" + id);
            await _daprClient.InvokeMethodAsync(HttpMethod.Delete, "dapr-api", $"api/todoitem/{id}");
            return RedirectToAction("Index");
        }

        [ActionName("Details")]
        public async Task<ActionResult> DetailsAsync(string id)
        {
            // var response = await _httpClient.GetAsync("api/todoitem/" + id);
            // var content = await response.Content.ReadAsStringAsync();
            // var item = JsonConvert.DeserializeObject<ToDoItem>(content);
            var item = await _daprClient.InvokeMethodAsync<ToDoItem>(HttpMethod.Get, "dapr-api", $"api/todoitem/{id}");
            return View(item);
        }
    }
}