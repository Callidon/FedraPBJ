using Gadfly
using RDatasets

# Load data with only columns "exec time", "completeness" and "nb tuples"
function load(file, endpoints, strategy)
	x = readtable(file, header = false, separator = ' ')[:,[:x2,:x6,:x11]]
	names!(x, [ :time, :completeness, :tuples])
	x[:endpoints] = endpoints
	x[:strategy] = strategy
	return x
end

outputWatDivEngine = "../results/definitive/fed10e/federation3/outputFedXengineFEDERATION10Client"
outputWatDivFedra = "../results/definitive/fed10e/federation3/outputFedXFedraFEDERATION10Client"
outputWatDivPeneloop = "../results/definitive/fed10e/federation3/outputFedXFedra-PBJ-hybridFEDERATION10Client"

outputWatDiv20eEngine = "../results/definitive/fed20e/federation3/outputFedXengineFEDERATION20Client"
outputWatDiv20eFedra = "../results/definitive/fed20e/federation3/outputFedXFedraFEDERATION20Client"
outputWatDiv20ePeneloop = "../results/definitive/fed20e/federation3/outputFedXFedra-PBJ-hybridFEDERATION20Client"

outputWatDiv30eEngine = "../results/definitive/fed30e/federation3/outputFedXengineFEDERATION30Client"
outputWatDiv30eFedra = "../results/definitive/fed30e/federation3/outputFedXFedraFEDERATION30Client"
outputWatDiv30ePeneloop = "../results/definitive/fed30e/federation3/outputFedXFedra-PBJ-hybridFEDERATION30Client"

Engine = load(outputWatDivEngine, "10 endpoints", "F")
Fedra = load(outputWatDivFedra, "10 endpoints", "F+F")
Peneloop = load(outputWatDivPeneloop, "10 endpoints", "F+F+P")

Engine20e = load(outputWatDiv20eEngine, "20 endpoints", "F")
Fedra20e = load(outputWatDiv20eFedra, "20 endpoints", "F+F")
Peneloop20e = load(outputWatDiv20ePeneloop, "20 endpoints", "F+F+P")

Engine30e = load(outputWatDiv30eEngine, "30 endpoints", "F")
Fedra30e = load(outputWatDiv30eFedra, "30 endpoints", "F+F")
Peneloop30e = load(outputWatDiv30ePeneloop, "30 endpoints", "F+F+P")

all = [Engine;Fedra;Peneloop;Engine20e;Fedra20e;Peneloop20e;Engine30e;Fedra30e;Peneloop30e]
results10e = [Engine;Fedra;Peneloop]
results20e = [Engine20e;Fedra20e;Peneloop20e]
results30e = [Engine30e;Fedra30e;Peneloop30e]

# plots
timeAll = plot(all, xgroup=:endpoints, x=:strategy, y=:time, Geom.subplot_grid(Geom.boxplot), Guide.xlabel("Number of endpoints in federation"), Guide.ylabel("Execution time (s)"), Scale.x_discrete, Scale.y_log10)

tuplesAll = plot(all, xgroup=:endpoints, x=:strategy, y=:tuples, Geom.subplot_grid(Geom.boxplot), Guide.xlabel("Number of endpoints in federation"), Guide.ylabel("Number of transferred tuples"), Scale.x_discrete, Scale.y_log10)

complAll = plot(all, xgroup=:endpoints, x=:strategy, y=:completeness, Geom.subplot_grid(Geom.boxplot), Guide.xlabel("Number of endpoints in federation"), Guide.ylabel("Answer completeness"), Scale.x_discrete)

density = plot([Fedra;Peneloop;Fedra20e;Peneloop20e;Fedra30e;Peneloop30e], xgroup=:endpoints, color=:strategy, y=:tuples, x=:time, Geom.subplot_grid(Geom.density), Scale.x_log10)

# save in PDF
draw(PDF("execution_time.pdf", 7inch, 5inch), timeAll)
draw(PDF("transferred_tuples.pdf", 7inch, 5inch), tuplesAll)
draw(PDF("completeness.pdf", 7inch, 4inch), complAll)
draw(PDF("density.pdf", 15inch, 4inch), density)
