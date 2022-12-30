namespace todo.Models
{
    using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;
    using Newtonsoft.Json;

    public class Item
    {
        [JsonProperty(PropertyName = "id"), ValidateNever()]
        public string Id { get; set; }

        [JsonProperty(PropertyName = "name")]
        public string Name { get; set; }

        [JsonProperty(PropertyName = "description")]
        public string Description { get; set; }

        [JsonProperty(PropertyName = "isComplete")]
        public bool Completed { get; set; }
    }
}