defmodule Anydrop.Accounts.ProfileToken do

  @salt_for_login "qAAJSbHk"
  @salt_for_profile "FbgggmBP"
  @salt_for_registration "mQJBViou"
  @max_age_for_login_token 60 * 5
  @max_age_for_profile_token 60 * 60
  @max_age_for_registration_token 60 * 2

  def generate_signed_token(data, context) do
    otp = create_otp(context)

    data =
      data
      |> encode_to_json()
      |> encode_to_url()

    case data do
      :error ->
        :error
      _ ->
        token = Phoenix.Token.sign(get_secret_key() <> otp, salt_for(context), data)
        {token, otp}
    end
  end

  def verify_signed_token(token, context, otp \\ "") do
    case Phoenix.Token.verify(get_secret_key() <> otp, salt_for(context), token, max_age: max_age_for(context)) do
      {:ok, data_url} ->
        data_map =
          data_url
          |> decode_from_url()
          |> decode_from_json()
        {:ok, data_map}
      {:error, reason} -> {:error, reason}
    end
  end

  def encode_to_url(:error) do
    :error
  end

  def encode_to_url(data) do
    Base.url_encode64(data, padding: false)
  end

  def decode_from_url(data) do
    Base.url_decode64!(data, padding: false)
  end

  def encode_to_json(data) do
    case Jason.encode(data) do
      {:ok, encoded_jason} -> encoded_jason
      {:error, _reason} -> :error
    end
  end

  def decode_from_json(data) do
    case Jason.decode(data) do
      {:ok, decoded_jason} -> decoded_jason
      {:error, _reason} -> :error
    end
  end

  defp get_secret_key do
    Application.get_env(:anydrop, AnydropWeb.Endpoint)[:secret_key_base]
  end

  defp create_otp("login") do
    Enum.random(1_00_000..9_99_999) |> Integer.to_string()
  end

  defp create_otp(_), do: ""

  defp salt_for("login"), do: @salt_for_login
  defp salt_for("profile"), do: @salt_for_profile
  defp salt_for("registration"), do: @salt_for_registration

  defp max_age_for("login"), do: @max_age_for_login_token
  defp max_age_for("profile"), do: @max_age_for_profile_token
  defp max_age_for("registration"), do: @max_age_for_registration_token


  # @doc """
  # Generates a token that will be stored in a signed place,
  # such as session or cookie. As they are signed, those
  # tokens do not need to be hashed.

  # The reason why we store session tokens in the database, even
  # though Phoenix already provides a session cookie, is because
  # Phoenix' default session cookies are not persisted, they are
  # simply signed and potentially encrypted. This means they are
  # valid indefinitely, unless you change the signing/encryption
  # salt.

  # Therefore, storing them allows individual user
  # sessions to be expired. The token system can also be extended
  # to store additional data, such as the device used for logging in.
  # You could then use this information to display all valid sessions
  # and devices in the UI and allow users to explicitly expire any
  # session they deem invalid.
  # """
  # def build_session_token(user) do
  #   token = :crypto.strong_rand_bytes(@rand_size)
  #   {token, %UserToken{token: token, context: "session", user_id: user.id}}
  # end

  # @doc """
  # Checks if the token is valid and returns its underlying lookup query.

  # The query returns the user found by the token, if any.

  # The token is valid if it matches the value in the database and it has
  # not expired (after @session_validity_in_days).
  # """
  # def verify_session_token_query(token) do
  #   query =
  #     from token in by_token_and_context_query(token, "session"),
  #       join: user in assoc(token, :user),
  #       where: token.inserted_at > ago(@session_validity_in_days, "day"),
  #       select: user

  #   {:ok, query}
  # end

  # @doc """
  # Builds a token and its hash to be delivered to the user's email.

  # The non-hashed token is sent to the user email while the
  # hashed part is stored in the database. The original token cannot be reconstructed,
  # which means anyone with read-only access to the database cannot directly use
  # the token in the application to gain access. Furthermore, if the user changes
  # their email in the system, the tokens sent to the previous email are no longer
  # valid.

  # Users can easily adapt the existing code to provide other types of delivery methods,
  # for example, by phone numbers.
  # """
  # def build_email_token(user, context) do
  #   build_hashed_token(user, context, user.email)
  # end

  # defp build_hashed_token(user, context, sent_to) do
  #   token = :crypto.strong_rand_bytes(@rand_size)
  #   hashed_token = :crypto.hash(@hash_algorithm, token)

  #   {Base.url_encode64(token, padding: false),
  #    %UserToken{
  #      token: hashed_token,
  #      context: context,
  #      sent_to: sent_to,
  #      user_id: user.id
  #    }}
  # end

  # @doc """
  # Checks if the token is valid and returns its underlying lookup query.

  # The query returns the user found by the token, if any.

  # The given token is valid if it matches its hashed counterpart in the
  # database and the user email has not changed. This function also checks
  # if the token is being used within a certain period, depending on the
  # context. The default contexts supported by this function are either
  # "confirm", for account confirmation emails, and "reset_password",
  # for resetting the password. For verifying requests to change the email,
  # see `verify_change_email_token_query/2`.
  # """
  # def verify_email_token_query(token, context) do
  #   case Base.url_decode64(token, padding: false) do
  #     {:ok, decoded_token} ->
  #       hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
  #       days = days_for_context(context)

  #       query =
  #         from token in by_token_and_context_query(hashed_token, context),
  #           join: user in assoc(token, :user),
  #           where: token.inserted_at > ago(^days, "day") and token.sent_to == user.email,
  #           select: user

  #       {:ok, query}

  #     :error ->
  #       :error
  #   end
  # end

  # defp days_for_context("confirm"), do: @confirm_validity_in_days
  # defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  # @doc """
  # Checks if the token is valid and returns its underlying lookup query.

  # The query returns the user found by the token, if any.

  # This is used to validate requests to change the user
  # email. It is different from `verify_email_token_query/2` precisely because
  # `verify_email_token_query/2` validates the email has not changed, which is
  # the starting point by this function.

  # The given token is valid if it matches its hashed counterpart in the
  # database and if it has not expired (after @change_email_validity_in_days).
  # The context must always start with "change:".
  # """
  # def verify_change_email_token_query(token, "change:" <> _ = context) do
  #   case Base.url_decode64(token, padding: false) do
  #     {:ok, decoded_token} ->
  #       hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

  #       query =
  #         from token in by_token_and_context_query(hashed_token, context),
  #           where: token.inserted_at > ago(@change_email_validity_in_days, "day")

  #       {:ok, query}

  #     :error ->
  #       :error
  #   end
  # end

  # @doc """
  # Returns the token struct for the given token value and context.
  # """
  # def by_token_and_context_query(token, context) do
  #   from UserToken, where: [token: ^token, context: ^context]
  # end

  # @doc """
  # Gets all tokens for the given user for the given contexts.
  # """
  # def by_user_and_contexts_query(user, :all) do
  #   from t in UserToken, where: t.user_id == ^user.id
  # end

  # def by_user_and_contexts_query(user, [_ | _] = contexts) do
  #   from t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts
  # end
end
