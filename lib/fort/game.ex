defmodule Fort.Game do
  @resource_types [:food, :timber, :stone, :iron]
  @building_types [:house, :field]

  defstruct resources: Enum.map(@resource_types, &{&1, 0}) |> Map.new(),
            buildings: Enum.map(@building_types, &{&1, 0}) |> Map.new()

  def resource_types, do: @resource_types
  def building_types, do: @building_types
end
