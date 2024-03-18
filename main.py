import streamlit as st
import pandas as pd
import plotly.express as px
import os
def file_selector(folder_path="./data/", type=""):
        folder_path = folder_path + type
        filenames = os.listdir(folder_path)
        csvFiles = []
        for file in filenames:
            if "csv" in file:
                csvFiles.append(file)
        selected_filename = st.selectbox("Select " + type, csvFiles)
        return os.path.join(folder_path, selected_filename)
selectedFile = file_selector()
df = pd.read_csv(selectedFile)
simpleDF = df[["instructor", "average_gpa", "rating"]]

fig = px.scatter(simpleDF, x='rating', y='average_gpa',
              color='instructor')

st.header(str(selectedFile.replace("./data/", "").replace(".csv", "")) + " Rating vs GPA")
st.plotly_chart(fig, use_container_width=True)

meanDF = simpleDF
groupedByInstructorGPA = simpleDF.groupby(simpleDF["instructor"])['average_gpa'].mean()
groupedByInstructorRating = simpleDF.groupby(simpleDF["instructor"])['rating'].mean()

col, col2 = st.columns(2)
df_merged = pd.merge(groupedByInstructorGPA, groupedByInstructorRating, how="inner", on="instructor")
col.dataframe(df_merged, width=300)
try:
        col2.header("Highest Rank: " + df_merged.idxmax())
except:
        st.error("Not enough data")
