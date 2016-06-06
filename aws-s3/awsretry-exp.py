import pandas
import matplotlib.pyplot

df = pandas.DataFrame.from_csv("awsretry-exp.csv")

ax = df.plot(stacked=False, kind="line", title="AWS S3 file upload empirical observation: transmission size", colormap="coolwarm_r", yticks=[0,1,2])

patches, labels = ax.get_legend_handles_labels()
ax.legend(patches, labels, loc="lower left")

matplotlib.pyplot.show()
