defmodule BitMsgHttp.UIBuilder do
  
  def start_link do
    Task.start_link(fn () -> 
      System.cmd("npm", ["start"])
    end)
  end
end