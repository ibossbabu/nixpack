return {
  {
    "snack.picker",
    keys = {
      { "<leader>sc", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>sf", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      { "<leader>sg", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sl", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>sr", function() Snacks.picker.resume() end, desc = "Resume" },
      { "<leader>so", function() Snacks.picker.recent() end, desc = "Recent" },
    },
  },
}
