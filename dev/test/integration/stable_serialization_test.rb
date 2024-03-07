require_relative '../test_helper'

class StableSerializationTest < Minitest::Test
  def teardown
    Category.destroy_all
    Property.destroy_all
    PropertyValue.destroy_all
  end

  def test_seed_imports_all_data_correctly
    raw_attributes_data = YAML.load_file("#{Application.root}/data/attributes/attributes.yml")
    DB::Seed.attributes_from(raw_attributes_data)

    assert_equal raw_attributes_data.size, Property.count
    raw_attributes_data.each do |raw_attribute|
      deserialized_attribute = Serializers::Data::PropertySerializer.deserialize(raw_attribute)
      real_attribute = Property.find(raw_attribute.fetch('id'))

      assert_equal deserialized_attribute, real_attribute
    end

    category_files = Dir.glob("#{Application.root}/data/categories/*.yml")
    raw_verticals_data = category_files.map { YAML.load_file(_1) }
    DB::Seed.categories_from(raw_verticals_data)

    assert_equal raw_verticals_data.size, Category.verticals.count
    assert_equal raw_verticals_data.map(&:size).sum, Category.count
    raw_verticals_data.flatten.each do |raw_category|
      deserialized_category = Serializers::Data::CategorySerializer.deserialize(raw_category)
      real_category = Category.find(raw_category.fetch('id'))

      assert_equal deserialized_category, real_category
    end
  end
end
