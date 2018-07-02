defmodule CodeFund.Schema.PropertyTest do
  use CodeFund.DataCase
  alias CodeFund.Schema.Property
  import CodeFund.Factory

  describe "properties" do
    setup do
      valid_attrs =
        build(:property, name: "Some Thing", user_id: insert(:user).id) |> Map.from_struct()

      {:ok, %{valid_attrs: valid_attrs}}
    end

    test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
      assert Property.changeset(%Property{}, valid_attrs).valid?
    end

    test "changeset with non_unique slug", %{valid_attrs: valid_attrs} do
      {:ok, property} = CodeFund.Properties.create_property(valid_attrs |> Map.delete(:slug))
      assert property.slug == "some_thing"
      changeset = Property.changeset(%Property{}, valid_attrs)
      assert Regex.match?(~r/some_thing_\d*/, changeset.changes.slug)
    end

    test "changeset with missing required attributes", %{valid_attrs: valid_attrs} do
      required_fields = Property.required() |> Enum.reject(fn attr -> attr == :slug end)
      SharedExample.ModelTests.required_attribute_test(Property, required_fields, valid_attrs)
    end

    test "changeset with invalid screenshot_url & url", %{valid_attrs: valid_attrs} do
      SharedExample.ModelTests.url_validation_test(Property, :url, valid_attrs)
      SharedExample.ModelTests.url_validation_test(Property, :screenshot_url, valid_attrs)
    end
  end
end
