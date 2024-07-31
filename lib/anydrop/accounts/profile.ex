defmodule Anydrop.Accounts.Profile do
  use Anydrop.Schema
  import Ecto.Changeset

  schema "profiles" do
    field :email, :string
    field :handle, :string
    field :display_name, :string
    field :type, :string

    belongs_to :user, Anydrop.Accounts.User
    has_many :drops, Anydrop.DropContext.Drop
    timestamps(type: :utc_datetime)
  end

  @doc """
  A profile changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(profile, attrs, opts \\ []) do
    profile
    |> cast(attrs, [:email, :handle, :display_name])
    |> validate_email(opts)
    |> validate_handle(opts)
    |> validate_display_name()
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 64)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_display_name(changeset) do
    changeset
    |> validate_required([:display_name])
    |> validate_format(:display_name, ~r/^[A-Za-z ]+$/, message: "only alphabetic characters")
    |> validate_length(:display_name, min: 5, max: 32)
  end

  defp validate_handle(changeset, opts) do
    changeset
    |> validate_required([:handle])
    |> validate_length(:handle, min: 5, max: 32)
    |> validate_format(:handle, ~r/^[a-zA-Z0-9_.-]+$/, message: "only alphanumeric characters, underscore, period and/or hyphen is allowed")
    |> maybe_validate_unique_handle(opts)
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Anydrop.Repo)
      |> unique_constraint(:email, name: :profiles_email_type_index)
    else
      changeset
    end
  end

  defp maybe_validate_unique_handle(changeset, opts) do
    if Keyword.get(opts, :validate_handle, true) do
      changeset
      |> unsafe_validate_unique(:handle, Anydrop.Repo)
      |> unique_constraint(:handle, name: :profiles_handle_type_index)
    else
      changeset
    end
  end

  @doc """
  A profile changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(profile, attrs, opts \\ []) do
    profile
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end
end
