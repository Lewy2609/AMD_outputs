import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)

# Fundamentals
import matplotlib.pyplot as plt

df=pd.read_csv('2t_4c_A\System_calls_finalloop.csv')
#print(df.head())
df.drop(df.columns[[0]], axis=1, inplace=True)
average_data = df.groupby('Number of Threads').mean()
#print(average_data.head())

# FOR ONE SYSTEM CALL ONLY - HISTOGRAM

######################

# system_call = 'read'
# average_data = df.groupby('Number of Threads')[system_call].mean()


# plt.figure(figsize=(10, 8))
# bars = plt.bar(average_data.keys(), average_data.values, color='skyblue')
# plt.xlabel('Number of Threads')
# plt.ylabel('Number of Calls')
# plt.title('System Call - Read')
# plt.xticks(average_data.keys())

# # Annotate bars with their values
# for bar, value in zip(bars, average_data.values):
#     plt.text(bar.get_x() + bar.get_width() / 2, value + 100, str(round(value, 2)), ha='center', va='bottom')

# plt.show()

#######################

# FOR ALL OR SELECTED SYSTEM CALLS - HISTOGRAM

#######################

# # # List of all system calls to be visualized
# # #system_calls = average_data.columns[1:]

# # List of selected system calls to be visualized
# system_calls = ['futex','mmap','mprotect','write']


# # Calculate the number of selected system calls
# num_calls = len(system_calls)

# # Determine the number of rows and columns
# num_cols = 3  # Set the number of columns per row

# # Calculate the number of rows needed
# num_rows = (num_calls + num_cols - 1) // num_cols

# # Create subplots for selected system calls with increased gap
# fig, axes = plt.subplots(nrows=num_rows, ncols=num_cols, figsize=(15, 5 * num_rows))
# fig.subplots_adjust(hspace=0.5,wspace=0.3)
# fig.suptitle('Histograms of Average System Calls made per Thread', fontsize=16)

# for i, call in enumerate(system_calls):
#     if num_calls == 1:
#         ax=axes[i]
#     elif num_calls >1 and num_rows == 1:
#         ax=axes[i % num_cols]
#     else:
#         ax = axes[i // num_cols, i % num_cols]
#     x_values = np.arange(len(average_data.index))  # Use the index as x values
#     bars = ax.bar(x_values, average_data[call], color='skyblue')
#     ax.set_xticks(x_values)
#     ax.set_xticklabels(average_data.index)
#     ax.set_xlabel('Number of Threads')
#     ax.set_ylabel('Average Count')
#     ax.set_title(f'Histogram of {call}')
    
#     # Annotate bars with their values
#     for bar, value in zip(bars, average_data[call]):
#         ax.annotate(str(round(value, 2)), xy=(bar.get_x() + bar.get_width() / 2, value), ha='center', va='bottom')

# # Remove any empty subplots
# for i in range(num_calls, num_rows * num_cols):
#     fig.delaxes(axes.flatten()[i])

# plt.show()

######################

# FOR GROUPED BAR CHART

#######################

# # Convert the dictionary to a DataFrame and transpose it
# average_data_df = pd.DataFrame(average_data).T

# # Set the figure size
# plt.figure(figsize=(12, 6))

# #print(average_data_df)

# ## FOR SELECTED SYSTEM CALLS

# # List of specific system calls you want to include
# selected_system_calls = ['futex','read','write','mmap','mprotect']

# # Filter the DataFrame to include only the selected system calls
# average_data_df = average_data_df.loc[selected_system_calls]

# ## FOR ALL SYSTEM CALLS

# # Get the list of system calls (x-axis labels)
# system_calls = average_data_df.index

# # Get the number of threads (x-axis)
# num_threads = average_data_df.columns
# len_num_threads = len(num_threads)

# # Calculate the width of each bar
# bar_width = 0.05
# group_width = bar_width * len_num_threads

# # Create a group of bars for each number of threads
# for i, thread in enumerate(num_threads):
#     x = np.arange(len(system_calls))
#     plt.bar(x + i * bar_width, average_data_df[thread], width=bar_width, label=f'{thread} Threads')

#     # Add data labels for the first and last threads in each group
#     for i, call in enumerate(system_calls):
#         plt.text(x[i], average_data_df.iloc[i, 0] + 5, str(round(average_data_df.iloc[i, 0], 2)), ha='center')
#         plt.text(x[i] + group_width, average_data_df.iloc[i, -1] + 5, str(round(average_data_df.iloc[i, -1], 2)), ha='center')


# # Set the x-axis ticks and labels
# plt.xticks(x + bar_width * (len_num_threads - 1) / 2, system_calls, rotation=45, ha='right')

# # Set labels and title
# plt.xlabel('System Calls')
# plt.ylabel('Average Number of System Calls')
# plt.title('System Calls vs. Average Number of System Calls per Thread')

# # Add a legend
# plt.legend(bbox_to_anchor=(1, 0.75))

# plt.show()

######################

# Convert the dictionary to a DataFrame and transpose it
average_data_df = pd.DataFrame(average_data).T

# Set the figure size
plt.figure(figsize=(12, 6))

#print(average_data_df)

## FOR SELECTED SYSTEM CALLS

# List of specific system calls you want to include
selected_system_calls = ['futex','read','write','mmap','mprotect']

# Filter the DataFrame to include only the selected system calls
average_data_df = average_data_df.loc[selected_system_calls]

## FOR ALL SYSTEM CALLS

# Get the list of system calls (x-axis labels)
system_calls = average_data_df.index

# Get the number of threads (x-axis)
num_threads = average_data_df.columns
len_num_threads = len(num_threads)

# Calculate the width of each bar
bar_width = 0.05
group_width = bar_width * len_num_threads

# Create a group of bars for each number of threads
for i, thread in enumerate(num_threads):
    x = np.arange(len(system_calls))
    plt.bar(x + i * bar_width, average_data_df[thread], width=bar_width, label=f'{thread} Threads')

    # Add data labels for the first and last threads in each group
    for i, call in enumerate(system_calls):
        plt.text(x[i], average_data_df.iloc[i, 0] + 5, str(round(average_data_df.iloc[i, 0], 2)), ha='center')
        plt.text(x[i] + group_width, average_data_df.iloc[i, -1] + 5, str(round(average_data_df.iloc[i, -1], 2)), ha='center')


# Set the x-axis ticks and labels
plt.xticks(x + bar_width * (len_num_threads - 1) / 2, system_calls, rotation=45, ha='right')

# Set labels and title
plt.xlabel('System Calls')
plt.ylabel('Average Number of System Calls')
plt.title('System Calls vs. Average Number of System Calls per Thread')

# Add a legend
plt.legend(bbox_to_anchor=(1, 0.75))

plt.show()