defmodule EXGBoostTest do
  alias ElixirLS.LanguageServer.Server.Decider
  alias EXGBoost.DMatrix
  alias EXGBoost.Booster
  use ExUnit.Case, async: true

  setup do
    {x, y} = Scidata.Iris.download()
    data = Enum.zip(x, y) |> Enum.shuffle()
    {train, test} = Enum.split(data, ceil(length(data) * 0.8))
    {x_train, y_train} = Enum.unzip(train)
    {x_test, y_test} = Enum.unzip(test)

    x_train = Nx.tensor(x_train)
    y_train = Nx.tensor(y_train)

    x_test = Nx.tensor(x_test)
    y_test = Nx.tensor(y_test)

    %{
      x_train: x_train,
      y_train: y_train,
      x_test: x_test,
      y_test: y_test
    }
  end

  test "protocol implementation", context do
    booster =
      EXGBoost.train(context.x_train, context.y_train, num_class: 3, objective: :multi_softprob)

    trees = DecisionTree.trees(booster)
    # assert is_list(trees)
    # assert is_struct(hd(trees), Mockingjay.Tree)
    assert DecisionTree.num_classes(booster) == 3
    assert DecisionTree.num_features(booster) == 4
    assert DecisionTree.output_type(booster) == :classification
  end
end
