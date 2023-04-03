using Dapr.Client;
using todo.Services;
using ToDoWebApp.API.Models;

namespace ToDoWebApp.API.Services
{
    //public class DaprToDoItemDbService:IToDoItemDbService
    //{
    //    const string STORE_NAME = "todostatestore";

    //    private readonly DaprClient _daprClient;

    //    public DaprToDoItemDbService(DaprClient daprClient)
    //    {
    //        _daprClient = daprClient;
    //    }

    //    public Task AddItemAsync(ToDoItem item)
    //    {
    //        throw new NotImplementedException();
    //    }

    //    public Task DeleteItemAsync(string id)
    //    {
    //        await _daprClient.DeleteStateAsync(STORE_NAME, id);
    //    }

    //    public Task<ToDoItem> GetItemAsync(string id)
    //    {
    //        throw new NotImplementedException();
    //    }

    //    public Task<IEnumerable<ToDoItem>> GetItemsAsync(string query)
    //    {
    //        throw new NotImplementedException();
    //    }

    //    public Task UpdateItemAsync(string id, ToDoItem item)
    //    {
    //         await _daprClient.SaveStateAsync<ToDoItem>(STORE_NAME, item.Id, item);
    //    }
    //}
}
