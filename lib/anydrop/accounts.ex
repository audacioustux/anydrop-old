defmodule Anydrop.Accounts do
  @moduledoc """
  The Accounts context.
  """
  use AnydropWeb, :verified_routes
  import Ecto.Query, warn: false
  alias Anydrop.Repo

  alias Anydrop.Accounts.{ProfileToken, ProfileNotifier, Profile, User}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_profile_by_email(email) when is_binary(email) do
    Repo.get_by(Profile, email: email)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile!(id), do: Repo.get!(Profile, id)

  def get_profile_by_handle!(handle) do
    Repo.get_by(Profile, handle: handle)
  end

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_profile(attrs) do
    {:ok, user} = create_user(%{})

    user
    |> Ecto.build_assoc(:profiles)
    |> Profile.registration_changeset(attrs)
    |> Repo.insert()
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_profile_registration(%Profile{} = profile, attrs \\ %{}) do
    Profile.registration_changeset(profile, attrs, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_profile_email(profile, attrs \\ %{}) do
    Profile.email_changeset(profile, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_profile_email(profile, attrs) do
    profile
    |> Profile.email_changeset(attrs)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_profile_by_profile_token(token) do
    case verify_profile_token(token) do
      {:ok, %{"profile_id" => profile_id}} ->
        get_profile!(profile_id)
      {:error, _} -> nil
    end
  end

  def create_login_token_and_deliver_instruction(email) do
    case ProfileToken.generate_signed_token(%{"email" => email}, "login") do
      {token, otp} ->
        url = create_login_link(token, otp)
        ProfileNotifier.deliver_login_instructions(email, url, otp)
        token
      :error -> :error
    end
  end

  def verify_login_token(token, otp) do
    ProfileToken.verify_signed_token(token, "login", otp)
  end

  defp create_login_link(token, otp) do
    url(~p"/users/log_in?token=#{token}&otp=#{otp}")
  end

  def create_profile_token(profile) do
    claim = %{"profile_id" => profile.id}
    case ProfileToken.generate_signed_token(claim, "profile") do
      {token, _otp} -> token
      :error -> :error
    end
  end

  def verify_profile_token(token) do
     ProfileToken.verify_signed_token(token, "profile")
  end

  def create_registration_token(email) do
    claim = %{"email" => email}
    case ProfileToken.generate_signed_token(claim, "registration") do
      {token, _otp} -> token
      :error -> :error
    end
  end

  def verify_registration_token(token) do
    case ProfileToken.verify_signed_token(token, "registration") do
      {:ok, %{"email" => email}} -> email
      {:error, _} -> :error
    end
  end


  # @doc """
  # Updates the profile email using the given token.

  # If the token matches, the user email is updated and the token is deleted.
  # The confirmed_at date is also updated to the current time.
  # """
  # def update_user_email(user, token) do
  #   context = "change:#{user.email}"

  #   with {:ok, query} <- ProfileToken.verify_change_email_token_query(token, context),
  #        %UserToken{sent_to: email} <- Repo.one(query),
  #        {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
  #     :ok
  #   else
  #     _ -> :error
  #   end
  # end

  # defp user_email_multi(user, email, context) do
  #   changeset =
  #     user
  #     |> User.email_changeset(%{email: email})
  #     |> User.confirm_changeset()

  #   Ecto.Multi.new()
  #   |> Ecto.Multi.update(:user, changeset)
  #   |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  # end

  # @doc ~S"""
  # Delivers the update email instructions to the given user.

  # ## Examples

  #     iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
  #     {:ok, %{to: ..., body: ...}}

  # """
  # def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
  #     when is_function(update_email_url_fun, 1) do
  #   {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

  #   Repo.insert!(user_token)
  #   ProfileNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  # end

  # @doc """
  # Confirms a user by the given token.

  # If the token matches, the user account is marked as confirmed
  # and the token is deleted.
  # """
  # def confirm_user(token) do
  #   with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
  #        %User{} = user <- Repo.one(query),
  #        {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
  #     {:ok, user}
  #   else
  #     _ -> :error
  #   end
  # end

  # defp confirm_user_multi(user) do
  #   Ecto.Multi.new()
  #   |> Ecto.Multi.update(:user, User.confirm_changeset(user))
  #   |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  # end

  # @doc """
  # Resets the user password.

  # ## Examples

  #     iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
  #     {:ok, %User{}}

  #     iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def reset_user_password(user, attrs) do
  #   Ecto.Multi.new()
  #   |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
  #   |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
  #   |> Repo.transaction()
  #   |> case do
  #     {:ok, %{user: user}} -> {:ok, user}
  #     {:error, :user, changeset, _} -> {:error, changeset}
  #   end
  # end
end
