import pandas
import matplotlib.pyplot

df = pandas.DataFrame.from_csv("failtest-adaptive.csv")

ax = df.plot(stacked=True, kind="bar", title="AWS S3 file upload empirical observation: adaptive partsize", colormap="terrain_r")

barlist = filter(lambda x: isinstance(x, matplotlib.patches.Rectangle), ax.get_children())
for bar in list(barlist)[3:-1]:
	bar.set_facecolor("#fdff99")

patches, labels = ax.get_legend_handles_labels()
ax.legend(patches, labels, loc="center left")

matplotlib.pyplot.show()
