namespace ToDoWebApp.Client.Controllers
{
    using System;
    using System.Net.Http;
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Logging;
    using Newtonsoft.Json;
    using NuGet.Protocol.Plugins;
    using ToDoWebApp.Client.Models;

    public class ToDoItemController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly HttpClient _httpClient;
        public ToDoItemController(ILogger<HomeController> logger, IHttpClientFactory httpClientFactory)
        {
            _logger = logger;
            _httpClient = httpClientFactory.CreateClient("ToDoAPI");
        }

        [ActionName("Index")]
        public async Task<IActionResult> Index()
        {
            var response = await _httpClient.GetAsync("api/todoitem");
            var content = await response.Content.ReadAsStringAsync();
            var items = JsonConvert.DeserializeObject<IEnumerable<ToDoItem>>(content);

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
                await _httpClient.PostAsJsonAsync("api/todoitem", item);
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
                await _httpClient.PutAsJsonAsync("api/todoitem/"+ item.Id, item);
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

            var response = await _httpClient.GetAsync("api/todoitem/"+ id);
            var content = await response.Content.ReadAsStringAsync();
            var item = JsonConvert.DeserializeObject<ToDoItem>(content);

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

            var response = await _httpClient.GetAsync("api/todoitem/" + id);
            var content = await response.Content.ReadAsStringAsync();
            var item = JsonConvert.DeserializeObject<ToDoItem>(content);
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
            await _httpClient.DeleteAsync("api/todoitem/" + id);
            return RedirectToAction("Index");
        }

        [ActionName("Details")]
        public async Task<ActionResult> DetailsAsync(string id)
        {
            var response = await _httpClient.GetAsync("api/todoitem/" + id);
            var content = await response.Content.ReadAsStringAsync();
            var item = JsonConvert.DeserializeObject<ToDoItem>(content);
            return View(item);
        }
    }
}