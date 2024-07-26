defmodule Anydrop.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @primary_key {:id, Ecto.UUID, autogenerate: {Uniq.UUID, :uuid7, []}}

      # For foreign keys, we can use either `:binary_id` or UUID types
      @foreign_key_type Ecto.UUID

      # parse timestamps as `DateTime` (for better ISO 8601 serialization)
      @timestamps_opts [type: :utc_datetime]
    end
  end
end
