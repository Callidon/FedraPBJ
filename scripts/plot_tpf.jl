using Gadfly
using RDatasets

no_colors_guide = Theme(
  key_position = :none,
  bar_spacing = 10px,
)

Gadfly.push_theme(no_colors_guide)

# Concat results from three distinct runs
function concatRuns(run1, run2, run3)
  return hcat(run1, run2, run3)
end

# Compute the mean of three runs
function meanRun(runs)
  res = DataFrame(mean_value = [])
  for row in eachrow(runs)
    push!(res, [ mean(convert(Array, row)) ])
  end
  return res
end

# Custom color scale for plots
function colors()
 return Scale.color_discrete_manual(colorant"#990000", colorant"#ff4000", colorant"#ffbf00")
end

time_ref_1 = readtable("../results/extension/run1/execution_times_ref.csv")
time_ref_2 = readtable("../results/extension/run2/execution_times_ref.csv")
time_ref_3 = readtable("../results/extension/run3/execution_times_ref.csv")

time_2s_1 = readtable("../results/extension/run1/execution_times_2s.csv")
time_2s_2 = readtable("../results/extension/run2/execution_times_2s.csv")
time_2s_3 = readtable("../results/extension/run3/execution_times_2s.csv")

time_3s_1 = readtable("../results/extension/run1/execution_times_3s.csv")
time_3s_2 = readtable("../results/extension/run2/execution_times_3s.csv")
time_3s_3 = readtable("../results/extension/run3/execution_times_3s.csv")

time_5s_1 = readtable("../results/extension/run1/execution_times_5s.csv")
time_5s_2 = readtable("../results/extension/run2/execution_times_5s.csv")
time_5s_3 = readtable("../results/extension/run3/execution_times_5s.csv")

time_ref = meanRun(concatRuns(time_ref_1, time_ref_2, time_ref_3))
time_2s = meanRun(concatRuns(time_2s_1, time_2s_2, time_2s_3))
time_3s = meanRun(concatRuns(time_3s_1, time_3s_2, time_3s_3))
time_5s = meanRun(concatRuns(time_5s_1, time_5s_2, time_5s_3))

time_ref[:approach] = "1 server"
time_2s[:approach] = "2 servers"
time_3s[:approach] = "3 servers"
time_5s[:approach] = "4 servers"

all = [time_ref;time_2s;time_3s;time_5s]

plot_time = plot(all, x=:approach, y=:mean_value, color=:approach, Geom.boxplot, Guide.xlabel("Number of TPF servers"), Guide.ylabel("Execution time (s)"), Scale.y_continuous, colors())
draw(PDF("../results/execution_time_tpf.pdf", 5inch, 3inch), plot_time)
