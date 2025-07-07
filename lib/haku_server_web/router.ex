defmodule HakuServerWeb.Router do
  use HakuServerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HakuServerWeb do
    pipe_through :api

    get "/marketplace", MarketplaceController, :index

    get "/profile", ProfileController, :index
    post "/profile/lock", ProfileController, :lock
    post "/profile/unlock", ProfileController, :unlock

    get "/nfts", NftController, :index
    get "/nfts/:nft_id/mint", NftController, :mint
    get "/nfts/:nft_id/burn", NftController, :burn

    get "/leaderboard/:type", LeaderboardController, :index

    post "/slice", SliceController, :assign

    get "/list", ListController, :list
    post "/list", ListController, :create

    get "/offer", OfferController, :list
    post "/offer", OfferController, :create
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:haku_server, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: HakuServerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
