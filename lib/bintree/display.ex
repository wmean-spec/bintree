defmodule Bintree.Display do
  @moduledoc false

  alias Markex.Element
  import Markex.Element.Operators

  @space Element.new(" ")
  @down Element.new("|")
  @left Element.new("/")
  @right Element.new("\\")

  @spec format(Bintree.t()) :: String.t()
  def format(tree) do
    do_format(tree)
    |> Element.to_string()
  end

  @spec do_format(Bintree.t()) :: Element.t()
  defp do_format(%Bintree{value: value, left: left, right: right}) do
    len = String.length(to_string(value))

    value_for_elem =
      to_string(value) <>
        if rem(len, 2) == 0 do
          " "
        else
          ""
        end

    case {is_nil(left), is_nil(right)} do
      {true, true} -> Element.new(value_for_elem)
      {false, true} -> Element.new(value_for_elem) <~> @down <~> do_format(left)
      {true, false} -> Element.new(value_for_elem) <~> @down <~> do_format(right)
      {false, false} -> Element.new(value_for_elem) <~> @down <~> do_format_div(left, right)
    end
  end

  @spec do_format_div(Bintree.t(), Bintree.t()) :: Element.t()
  defp do_format_div(left, right) do
    columns =
      [left, right] = [
        @down <~> do_format(left),
        @down <~> do_format(right)
      ]

    elem =
      left
      |> Element.beside(@space)
      |> Element.beside(right, :top)

    connector(columns) <~> elem
  end

  @spec bar(String.t(), non_neg_integer()) :: Element.t()
  defp bar(symbol, len) do
    Element.new(symbol, len, 1)
  end

  @spec horizontal_bar(non_neg_integer()) :: Element.t()
  defp horizontal_bar(len) do
    bar("-", len)
  end

  @spec empty_bar(non_neg_integer()) :: Element.t()
  defp empty_bar(len) do
    bar(" ", len)
  end

  @spec connector([Element.t(), ...]) :: Element.t()
  defp connector([left, right]) do
    left_column_len = Element.width(left)

    half_left_column_len =
      if div(left_column_len, 2) == 1 do
        div(left_column_len - 1, 2)
      else
        div(left_column_len, 2)
      end

    left_connector =
      empty_bar(half_left_column_len)
      <|> @left
      <|> horizontal_bar(half_left_column_len)

    right_column_len = Element.width(right)

    half_right_column_len =
      if div(right_column_len, 2) == 1 do
        div(right_column_len - 1, 2)
      else
        div(right_column_len, 2)
      end

    right_connector =
      horizontal_bar(half_right_column_len)
      <|> @right
      <|> empty_bar(half_right_column_len)

    left_connector <|> horizontal_bar(1) <|> right_connector
  end
end
