defmodule BillionOak.Ingestion.Mannatech do
  require Logger
  use OK.Pipe
  alias BillionOak.{Repo, External, Identity, Filestore}
  alias BillionOak.Ingestion.Attempt

  def ingest(organization) do
    {:ok, company} = External.get_company("mannatech")
    prefix = s3_key(company.handle, organization.handle)
    start_after = organization.ingestion_cursor || "#{prefix}/0"

    Filestore.list_files(prefix, start_after)
    ~>> Enum.reduce_while({:ok, []}, fn s3_object, {:ok, acc} ->
      key = s3_object.key

      case ingest_accounts(organization, key) do
        {:ok, n} -> {:cont, {:ok, acc ++ [{key, {:ok, n}}]}}
        other -> {:halt, {:error, acc ++ [{key, other}]}}
      end
    end)
  end

  def ingest_accounts(organization, s3_key) do
    attempt = mark_started!(organization, s3_key)

    result =
      {:ok, s3_key}
      ~>> Filestore.stream_file()
      ~> Stream.map(&:unicode.characters_to_binary(&1, :latin1, :utf8))
      ~> CSV.decode(headers: true, separator: ?\t)
      ~> Stream.map(&account_attrs/1)
      ~> Stream.chunk_every(1000)
      ~> Stream.map(fn attrs_chunk ->
        External.ingest_data(attrs_chunk, organization)
      end)
      ~> Stream.transform(nil, fn
        _, {:halt, n} ->
          {:halt, n}

        result, _ ->
          case result do
            {:ok, _} -> {[result], result}
            {:error, _} -> {[result], {:halt, result}}
          end
      end)
      ~>> Enum.reduce_while({:ok, 0}, fn
        {:error, reason}, {:ok, n} -> {:halt, {:error, n, reason}}
        {:ok, n}, {:ok, acc} -> {:cont, {:ok, acc + n}}
      end)

    case result do
      {:ok, _} ->
        {:ok, _} = Identity.update_organization(organization, %{ingestion_cursor: s3_key})
        mark_succeeded!(attempt)
        result

      {:error, n, details} ->
        Logger.warning("Ingestion partially succeeded for #{n} records, failed for the rest.")
        {index, error} = Enum.at(details, 0)
        Logger.warning("First error occurred at index #{index}: #{inspect(error)}")

        mark_failed!(attempt)
        result
    end
  end

  defp account_status("RECENT"), do: :active
  defp account_status("FORMER"), do: :inactive
  defp account_status("INACTIVE"), do: :inactive
  defp account_status("TERMINATED"), do: :terminated

  defp enrolled_at(date_str) do
    case Timex.parse(date_str, "{0M}/{0D}/{YYYY}") do
      {:ok, date} -> date
      _ -> nil
    end
  end

  defp account_attrs({:ok, row}) do
    custom_data_keys = [
      "ORGENROLLMENTLEVEL",
      "CURRENTENROLLMENTLEVEL",
      "GRACEPERIODFLAG",
      "GRACEPERIODBP",
      "HIGHLDRLVL",
      "RENEWALBP",
      "ASSOCIATETYPE",
      "TERMINATED",
      "BPPBE",
      "MRELQV",
      "MRELDATE"
    ]

    custom_data = Map.take(row, custom_data_keys)

    content =
      Map.drop(
        row,
        custom_data_keys ++
          [
            "STATUS",
            "CTLNO",
            "NAME",
            "CITY",
            "STATE",
            "COUNTRY",
            "PHONENO",
            "EVPHONENO",
            "ENROLLMENTDATE",
            "SPONSORCTLNO",
            "ENROLLCTLNO",
            "SPONSORNAME",
            "SPONSORCOUNTRY",
            "ENROLLNAME",
            "ENROLLCOUNTRY"
          ]
      )

    phone1 = row["PHONENO"]
    phone2 = if row["EVPHONENO"] != phone1, do: row["EVPHONENO"], else: nil

    %{
      account: %{
        status: account_status(row["STATUS"]),
        rid: row["CTLNO"],
        name: row["NAME"],
        city: row["CITY"],
        state: row["STATE"],
        country_code: row["COUNTRY"],
        phone1: phone1,
        phone2: phone2,
        enrolled_at: enrolled_at(row["ENROLLMENTDATE"]),
        sponsor_rid: row["SPONSORCTLNO"],
        enroller_rid: row["ENROLLCTLNO"],
        custom_data: custom_data
      },
      record: %{
        company_account_rid: row["CTLNO"],
        content: content
      }
    }
  end

  defp s3_key(company_handle, org_handle),
    do: "ingestion/#{company_handle}/#{org_handle}/mtku"

  defp mark_started!(organization, s3_key) do
    attrs = %{
      s3_key: s3_key,
      company_id: organization.company_id,
      organization_id: organization.id,
      format: "mtku"
    }

    %Attempt{}
    |> Attempt.changeset(attrs)
    |> Repo.insert!()
  end

  defp mark_succeeded!(attempt) do
    attempt
    |> Attempt.changeset(%{status: :succeeded})
    |> Repo.update!()
  end

  defp mark_failed!(attempt) do
    attempt
    |> Attempt.changeset(%{status: :failed})
    |> Repo.update!()
  end
end
