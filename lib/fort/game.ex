defmodule Fort.Game do
  defmodule Building do
    @types [:house, :farm, :lumberjack, :stone_quarry, :iron_mine]

    def types, do: @types

    def name_for_type(type), do: type |> Atom.to_string() |> String.replace("_", " ")

    def effect_for(building_type, count), do: effects()[building_type].(count)

    def cost_of(building_type, current_level), do: costs()[building_type].(current_level)

    defp costs do
      %{
        house: fn current_level ->
          %{food: 10 * current_level, timber: 10 * current_level}
        end,
        farm: fn current_level ->
          %{timber: 10 * current_level}
        end,
        lumberjack: fn current_level ->
          %{food: 10 * current_level}
        end,
        stone_quarry: fn current_level ->
          %{food: 10 * current_level, timber: 10 * current_level}
        end,
        iron_mine: fn current_level ->
          %{food: 10 * current_level, timber: 10 * current_level, stone: 10 * current_level}
        end
      }
    end

    defp effects do
      %{
        house: fn _ -> {:noop} end,
        farm: fn count -> {:add_resource, :food, count * 10} end,
        lumberjack: fn count -> {:add_resource, :timber, count * 10} end,
        stone_quarry: fn count -> {:add_resource, :stone, count * 10} end,
        iron_mine: fn count -> {:add_resource, :iron, count * 10} end
      }
    end
  end

  defmodule Resource do
    @types [:food, :timber, :stone, :iron]

    def types, do: @types

    def name_for_type(type), do: type |> Atom.to_string() |> String.replace("_", " ")
  end

  defstruct [:resources, :buildings]

  def new() do
    %__MODULE__{
      resources: Enum.map(Resource.types(), &{&1, 0}) |> Map.new(),
      buildings: Enum.map(Building.types(), &{&1, 0}) |> Map.new()
    }
  end

  # buildings

  def building_level(game, building_type) do
    game.buildings |> Map.get(building_type)
  end

  def build(game, building_type) do
    cost = Building.cost_of(building_type, building_level(game, building_type))

    if have_resources(game, cost) do
      {:ok,
       game
       |> upgrade_building(building_type)
       |> spend_resources(cost)}
    else
      {:error, :not_enough_resources}
    end
  end

  defp upgrade_building(game, building_type) do
    %{game | buildings: Map.update!(game.buildings, building_type, &(&1 + 1))}
  end

  # resources

  def resource_amount(game, resource_type) do
    game.resources |> Map.get(resource_type)
  end

  def have_resources(game, resources) do
    Enum.all?(resources, fn {resource_type, amount} ->
      resource_amount(game, resource_type) >= amount
    end)
  end

  defp add_resource(game, resource_type, count) do
    %{game | resources: Map.update!(game.resources, resource_type, &(&1 + count))}
  end

  defp spend_resources(game, resources) do
    Enum.reduce(resources, game, fn {resource_type, amount}, game ->
      spend_resource(game, resource_type, amount)
    end)
  end

  defp spend_resource(game, resource_type, amount) do
    %{game | resources: Map.update!(game.resources, resource_type, &(&1 - amount))}
  end

  # updates

  def update(game) do
    game.buildings
    |> Enum.filter(fn {_, count} -> count > 0 end)
    |> Enum.reduce(game, fn {building_type, count}, game ->
      handle_effect(game, Building.effect_for(building_type, count))
    end)
  end

  defp handle_effect(game, effect) do
    case effect do
      {:add_resource, resource_type, count} -> add_resource(game, resource_type, count)
      {:noop} -> game
    end
  end
end
