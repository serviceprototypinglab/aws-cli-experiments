import pandas
import matplotlib.pyplot

df = pandas.DataFrame.from_csv("aws-s3-test.csv")

ax = df.plot(stacked=True, kind="bar", title="AWS S3 file upload empirical observation: filesize vs. partsize", colormap="terrain_r")

patches, labels = ax.get_legend_handles_labels()
ax.legend(patches, labels, loc="lower left")

matplotlib.pyplot.show()
