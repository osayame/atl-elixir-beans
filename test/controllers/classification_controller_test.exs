defmodule Beans.ClassificationControllerTest do
  use Beans.ConnCase
  require Logger

  setup do
    Beans.Classification.start_link

    {:ok, %{
      bean_name: "pinto-#{:os.system_time(:seconds)}",
      class: "phaseolus-#{:os.system_time(:seconds)}"
    }}
  end

  test "200 GET /api/v1/classification valid bean name", %{conn: conn} do
    bean_name = "pinto"
    expected_class = "phaseolus"
    conn = get conn, "/api/v1/classification?bean_name=#{bean_name}"

    assert conn.status == 200
    resp_body = conn.resp_body |> Poison.decode!
    assert resp_body |> Map.has_key?("classification")
    assert resp_body |> Map.values == [expected_class]
  end

  test "404 GET /api/v1/classification missing bean name", %{conn: conn} do
    bean_name = "fake_bean"
    conn = get conn, "/api/v1/classification?bean_name=#{bean_name}"
    assert conn.status == 404
    assert conn.resp_body |> Poison.decode! |> Map.has_key?("error")
  end

  test "404 GET /api/v1/classification empty bean name", %{conn: conn} do
    bean_name = ""
    conn = get conn, "/api/v1/classification?bean_name=#{bean_name}"
    assert conn.status == 404
    assert conn.resp_body |> Poison.decode! |> Map.has_key?("error")
  end

  test "404 GET /api/v1/classification nil bean name", %{conn: conn} do
    conn = get conn, "/api/v1/classification"
    assert conn.status == 404
    assert conn.resp_body |> Poison.decode! |> Map.has_key?("error")
  end

  test "404 POST /api/v1/classification nil bean name", context do
    conn = context.conn
    |> post("/api/v1/classification?classification=#{context.class}")

    assert conn.status == 404
    assert conn.resp_body |> Poison.decode! |> Map.has_key?("error")
  end

  test "404 POST /api/v1/classification invalid classification", context do
    conn = context.conn
    |> post("/api/v1/classification?bean_name=#{context.bean_name}")

    assert conn.status == 404
    assert conn.resp_body |> Poison.decode! |> Map.has_key?("error")
  end

  test "200 POST /api/v1/classification invalid classification", context do
    assert Beans.Classification.get_classification(context.bean_name) != {:ok, context.class}

    conn = context.conn
    |> post("/api/v1/classification?bean_name=#{context.bean_name}&classification=#{context.class}")

    assert conn.status == 200
    assert conn.resp_body |> Poison.decode! |> Map.has_key?("success")
    assert Beans.Classification.get_classification(context.bean_name) == {:ok, context.class}
  end

end
