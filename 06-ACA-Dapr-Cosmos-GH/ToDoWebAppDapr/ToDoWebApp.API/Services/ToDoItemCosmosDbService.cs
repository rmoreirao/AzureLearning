//namespace todo.Services
//{
//    using System.Collections.Generic;
//    using System.Linq;
//    using System.Threading.Tasks;
//    using Microsoft.Azure.Cosmos;
//    using Microsoft.Azure.Cosmos.Fluent;
//    using Microsoft.Extensions.Configuration;
//    using ToDoWebApp.API.Models;

//    public class ToDoItemCosmosDbService : IToDoItemDbService
//    {
//        private Container _container;

//        public ToDoItemCosmosDbService(
//            CosmosClient dbClient,
//            string databaseName,
//            string containerName)
//        {
//            this._container = dbClient.GetContainer(databaseName, containerName);
//        }

//        public async Task AddItemAsync(ToDoItem item)
//        {
//            await this._container.CreateItemAsync<ToDoItem>(item, new PartitionKey(item.Id));
//        }

//        public async Task DeleteItemAsync(string id)
//        {
//            await this._container.DeleteItemAsync<ToDoItem>(id, new PartitionKey(id));
//        }

//        public async Task<ToDoItem> GetItemAsync(string id)
//        {
//            try
//            {
//                ItemResponse<ToDoItem> response = await this._container.ReadItemAsync<ToDoItem>(id, new PartitionKey(id));
//                return response.Resource;
//            }
//            catch (CosmosException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
//            {
//                return null;
//            }

//        }

//        public async Task<IEnumerable<ToDoItem>> GetItemsAsync(string queryString)
//        {
//            var query = this._container.GetItemQueryIterator<ToDoItem>(new QueryDefinition(queryString));
//            List<ToDoItem> results = new List<ToDoItem>();
//            while (query.HasMoreResults)
//            {
//                var response = await query.ReadNextAsync();

//                results.AddRange(response.ToList());
//            }

//            return results;
//        }

//        public async Task UpdateItemAsync(string id, ToDoItem item)
//        {
//            await this._container.UpsertItemAsync<ToDoItem>(item, new PartitionKey(id));
//        }
//    }
//}