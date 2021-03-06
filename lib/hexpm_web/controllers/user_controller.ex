defmodule HexpmWeb.UserController do
  use HexpmWeb, :controller

  def show(conn, %{"username" => username}) do
    user = Users.get_by_username(username, [:emails, :organization, owned_packages: :repository])

    if user do
      organization = user.organization

      case conn.path_info do
        ["users" | _] when not is_nil(organization) ->
          redirect(conn, to: Router.user_path(user))

        ["orgs" | _] when is_nil(organization) ->
          redirect(conn, to: Router.user_path(user))

        _ ->
          show_user(conn, user)
      end
    else
      not_found(conn)
    end
  end

  defp show_user(conn, user) do
    packages =
      Packages.accessible_user_owned_packages(user, conn.assigns.current_user)
      |> Packages.attach_versions()

    public_email = User.email(user, :public)
    gravatar_email = User.email(user, :gravatar)

    render(
      conn,
      "show.html",
      title: user.username,
      container: "container page user",
      user: user,
      packages: packages,
      public_email: public_email,
      gravatar_email: gravatar_email
    )
  end
end
