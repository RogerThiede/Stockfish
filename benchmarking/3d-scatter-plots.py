import plotly.express as px
import plotly.graph_objects as go
import pandas as pd
import numpy as np              # for calculating standard deviation and mean
import scipy.stats as stats     # for calculating standard error

# Input as csv format with columns:
#       "version, architecture, compiler, hashsize, threads, depth, nps1, nps2, nps3"

# depth9_fen is really only one architecture, x86-64-vnni512
# depth10_fen is all architectures
df = pd.read_csv('~/Documents/git/Stockfish/benchmarking/depth10_fen.csv')

df['mean_nps'] = (df['nps1'] + df['nps2'] + df['nps3']) // 3
df['max_nps'] = df.apply(lambda row: max(row.nps1, row.nps2, row.nps3), axis=1)
#df['high_to_mean'] = df.apply(lambda row: max(row.nps1, row.nps2, row.nps3) - row.mean_nps, axis=1)
#df['low_to_mean'] = df.apply(lambda row: row.mean_nps - min(row.nps1, row.nps2, row.nps3), axis=1)
print(df)

fig = px.scatter_3d(df, animation_frame="depth", x='threads', y='hashsize', z='max_nps', color='architecture', symbol='compiler')
fig.update_layout(title="max_nps of three nps")
fig.show()

# # Read data from a csv
# z_data = pd.read_csv('~/Documents/git/Stockfish/benchmarking/mt_bruno_elevation.csv')

# marks = {}.fromkeys([str(i) for i in range(19)], 'int32')
# z = z_data.astype(marks).values
# print("z.shape = ", z.shape)
# sh_0, sh_1 = z.shape
# y, x = np.linspace(0, 19, sh_0), np.linspace(0, 19, sh_1)
# print("linespace x:", x)
# print("linespace y:", y)
# print("z:", z)

# sh_0, sh_1 = (3, 9)
# #x, y = np.linspace(4096, 16384, sh_0), np.linspace(64, 512, sh_1)
# surface_map = df.pivot(index='hashsize', columns='threads', values='max_nps')
# y =  [4096, 8192, 16384]
# x =  list(surface_map.loc[0:0])

# print("linespace x:", x)
# print("linespace y:", y)
# print("z:", surface_map)
# fig = go.Figure(data=[go.Surface(x=x, y=y, z=surface_map.values)])
# fig.update_layout(title='Test', autosize=True)
# fig.update_scenes(xaxis_title_text='LooooooooooongX',  
#                   yaxis_title_text='LooooooooooongY',  
#                   zaxis_title_text='LooooooooooongZ')
# fig.show()

# print("Done")