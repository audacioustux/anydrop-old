defmodule Anydrop.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Anydrop.Accounts` context.
  """

  def unique_profile_email, do: "profile#{System.unique_integer()}@example.com"
  def valid_profile_password, do: "hello world!"

  def valid_profile_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_profile_email(),
      password: valid_profile_password()
    })
  end

  def profile_fixture(attrs \\ %{}) do
    {:ok, profile} =
      attrs
      |> valid_profile_attributes()
      |> Anydrop.Accounts.register_profile()

    profile
  end

  def extract_profile_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
