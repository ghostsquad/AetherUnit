namespace PondUnit.Attributes {
    using System;

    public class TraitAttribute : Attribute {
        public string Name { get; set; }

        public string Value { get; set; }
    }
}