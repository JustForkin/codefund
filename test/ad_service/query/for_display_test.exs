defmodule AdService.Query.ForDisplayTest do
  use CodeFund.DataCase
  import CodeFund.Factory

  setup do
    creative = insert(:creative)

    insert(:audience, %{
      programming_languages: ["Ruby", "C"],
      topic_categories: ["Programming"]
    })

    insert(:audience, %{
      programming_languages: ["Ruby", "C"],
      topic_categories: ["Development"]
    })

    audience =
      insert(:audience, %{
        programming_languages: ["Ruby", "C"],
        topic_categories: ["Programming"]
      })

    insert(:audience, %{
      programming_languages: ["Java", "Rust"],
      topic_categories: ["Development"]
    })

    campaign =
      insert(
        :campaign,
        status: 2,
        ecpm: Decimal.new("1.00"),
        budget_daily_amount: Decimal.new(1),
        total_spend: Decimal.new("100.00"),
        start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
        end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
        creative: creative,
        audience: audience,
        included_countries: ["US"]
      )

    insert(
      :campaign,
      status: 2,
      ecpm: Decimal.new(0),
      budget_daily_amount: Decimal.new(0),
      total_spend: Decimal.new(50),
      start_date: Timex.now() |> Timex.shift(days: -4) |> DateTime.to_naive(),
      end_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
      creative: creative,
      audience: audience,
      included_countries: ["US"]
    )

    insert(
      :campaign,
      status: 2,
      ecpm: Decimal.new(1),
      budget_daily_amount: Decimal.new(1),
      start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
      end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
      total_spend: Decimal.new(100),
      creative: creative,
      included_countries: ["IN"],
      audience: insert(:audience, %{programming_languages: ["Java", "Rust"]})
    )

    insert(
      :campaign,
      status: 1,
      ecpm: Decimal.new(1),
      budget_daily_amount: Decimal.new(1),
      total_spend: Decimal.new(100),
      start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
      end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
      creative: creative,
      audience: audience,
      included_countries: ["CN"]
    )

    {:ok, %{creative: creative, campaign: campaign}}
  end

  describe "build/1" do
    test "it returns advertisements by property filters", %{
      campaign: campaign,
      creative: creative
    } do
      advertisement =
        AdService.Query.ForDisplay.build(
          programming_languages: ["Rust"],
          topic_categories: ["Development"],
          client_country: "US"
        )
        |> CodeFund.Repo.one()

      assert advertisement == %AdService.Advertisement{
               body: creative.body,
               campaign_id: campaign.id,
               image_url: creative.image_url,
               headline: creative.headline,
               total_spend: campaign.total_spend
             }
    end

    test "get_by_property_filters excludes indicated countries" do
      refute AdService.Query.ForDisplay.build(
               programming_languages: ["Rust"],
               topic_categories: ["Development"],
               client_country: "CN"
             )
             |> CodeFund.Repo.one()
    end
  end
end