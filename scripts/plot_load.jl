using Gadfly
using DataFramesMeta
using RDatasets

no_colors_guide = Theme(
  key_position = :none,
  bar_spacing = 10px,
)

Gadfly.push_theme(no_colors_guide)

blacklist = [ 67 ]

label2 = "2 servers"
label3 = "3 servers"
label5 = "5 servers"

# Custom color scale for plots
function colors()
 return Scale.color_discrete_manual(colorant"#990000", colorant"#ff4000", colorant"#ffbf00")
end

function clean(df, blacklist)
  return where(groupby(df, [:query]), d -> ! (d[1, :query] in blacklist))
end

function computePercents2(df)
  groups = groupby(df, [:query])
  res = DataFrame(query = [], percent = [], total = [], server = [])
  for group in groups
    sumCalls = group[1, :calls] + group[2, :calls]
    push!(res, [ group[1, :query], (group[1, :calls] / sumCalls)*100, sumCalls, group[1, :server] ])
    push!(res, [ group[2, :query], (group[2, :calls] / sumCalls)*100, sumCalls, group[2, :server] ])
  end
  return res
end

function computePercents3(df)
  groups = groupby(df, [:query])
  res = DataFrame(query = [], percent = [], total = [], server = [])
  for group in groups
    sumCalls = group[1, :calls] + group[2, :calls] + group[3, :calls]
    push!(res, [ group[1, :query], (group[1, :calls] / sumCalls)*100, sumCalls, group[1, :server] ])
    push!(res, [ group[2, :query], (group[2, :calls] / sumCalls)*100, sumCalls, group[2, :server] ])
    push!(res, [ group[3, :query], (group[3, :calls] / sumCalls)*100, sumCalls, group[3, :server] ])
  end
  return res
end

function computePercents5(df)
  groups = groupby(df, [:query])
  res = DataFrame(query = [], percent = [], total = [], server = [])
  for group in groups
    sumCalls = group[1, :calls] + group[2, :calls] + group[3, :calls] + group[4, :calls] + group[5, :calls]
    push!(res, [ group[1, :query], (group[1, :calls] / sumCalls)*100, sumCalls, group[1, :server] ])
    push!(res, [ group[2, :query], (group[2, :calls] / sumCalls)*100, sumCalls, group[2, :server] ])
    push!(res, [ group[3, :query], (group[3, :calls] / sumCalls)*100, sumCalls, group[3, :server] ])
    push!(res, [ group[4, :query], (group[4, :calls] / sumCalls)*100, sumCalls, group[4, :server] ])
    push!(res, [ group[5, :query], (group[5, :calls] / sumCalls)*100, sumCalls, group[5, :server] ])
  end
  return res
end

function meanPercent2(df)
  return DataFrame(mean = [
      mean(df[df[:server] .== "E1", :][:percent]),
      mean(df[df[:server] .== "E2", :][:percent])
    ], server = [ "E1", "E2" ], approach = [label2,label2])
end
function meanPercent3(df)
  return DataFrame(mean = [
      mean(df[df[:server] .== "E1", :][:percent]),
      mean(df[df[:server] .== "E2", :][:percent]),
      mean(df[df[:server] .== "E3", :][:percent])
    ], server = [ "E1", "E2", "E3" ], approach = [label3,label3,label3])
end
function meanPercent5(df)
  return DataFrame(mean = [
      mean(df[df[:server] .== "E1", :][:percent]),
      mean(df[df[:server] .== "E2", :][:percent]),
      mean(df[df[:server] .== "E3", :][:percent]),
      mean(df[df[:server] .== "E4", :][:percent]),
      mean(df[df[:server] .== "E5", :][:percent])
    ], server = [ "E1", "E2", "E3", "E4", "E5" ], approach = [label5,label5,label5,label5,label5])
end

function processData(df, list)
  return DataFrame(clean(df, list))
end

calls_2 = processData(readtable("../results/extension/http_calls_2.csv"), blacklist)
calls_3 = processData(readtable("../results/extension/http_calls_3.csv"), blacklist)
calls_5 = processData(readtable("../results/extension/http_calls_5.csv"), blacklist)

percent_2 = meanPercent2(computePercents2(calls_2))
percent_3 = meanPercent3(computePercents3(calls_3))
percent_5 = meanPercent5(computePercents5(calls_5))

# percent_quartz_eq[:approach] = "TQ"
# percent_peneloop_eq[:approach] = "TP"
# percent_all_eq[:approach] = "TQP"

plot_percent = plot(percent_2, x=:server, y=:mean, color=:approach, Geom.bar, Guide.xlabel("2 servers"), Guide.ylabel("% of total HTTP calls", orientation=:vertical), Guide.colorkey(""), Guide.yticks(ticks=[0,10,20,30,40,50,60]), Scale.x_discrete, Scale.color_discrete_manual(colorant"#990000"))
plot_percent_2 = plot(percent_3, x=:server, y=:mean, color=:approach, Geom.bar, Guide.xlabel("3 servers"), Guide.ylabel(""), Guide.colorkey(""), Guide.yticks(ticks=[0,10,20,30,40,50,60], label=false), Scale.x_discrete, Scale.color_discrete_manual(colorant"#ff4000"))
plot_percent_3 = plot(percent_5, x=:server, y=:mean, color=:approach, Geom.bar, Guide.xlabel("5 servers"), Guide.ylabel(""), Guide.colorkey(""), Guide.yticks(ticks=[0,10,20,30,40,50,60], label=false), Scale.x_discrete, Scale.color_discrete_manual(colorant"#ffbf00"))

draw(PDF("../results/http_calls.pdf", 5inch, 3inch), hstack(plot_percent, plot_percent_2, plot_percent_3))
