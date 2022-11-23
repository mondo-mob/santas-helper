import re
import numpy as np
import pandas as pd


#########################################################################################################
#
# Helper classes & functions
#
#########################################################################################################

def decamel(df):
    return [camel_to_snake(c) for c in df]


def camel_to_snake(name):
    name = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', name).lower().replace("__", '_')


def remove_dup_columns(frame):
    keep_names = set()
    keep_icols = list()
    for icol, name in enumerate(frame.columns):
        if name not in keep_names:
            keep_names.add(name)
            keep_icols.append(icol)
    return frame.iloc[:, keep_icols]


class bq():

    def __init__(self, project_id='santas-helper', credentials_file='configuration.json'):
        import os
        import google.auth
        from google.cloud import bigquery
        from google.cloud import bigquery_storage

        os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_file

        credentials, your_project_id = google.auth.default(
            scopes=["https://www.googleapis.com/auth/cloud-platform"]
        )

        self.db = bigquery.Client(credentials=credentials, project=project_id, )

    def q(self, sql, verbose=True):
        import re, time, binascii

        then = time.time()
        import os
        path = 'cache/bq/' + re.sub('\W+', "_", sql[:200]) + '_' + str(binascii.crc32(bytes(sql, 'utf-8'))) + '.hdf'
        if os.path.exists(path):

            if verbose:
                print('from cache')
            df = pd.read_hdf(path)


        else:
            qq = self.db.query(sql)
            outs = []
            for r in qq.result():
                out = list(r)
                outs.append(out)
            # Note: there is a bug here where r is not defined if there are no rows returned
            df = pd.DataFrame(outs, columns=r.keys())
            df.columns = decamel(df)
            df = remove_dup_columns(df)
            try:
                df.to_hdf(path, 'z')
            except Exception as e:
                print('couldnt write: ', e)
        if verbose:
            print(df.shape, time.time() - then)

        return df


# Used to hold the allocations (included and not included). I.e.
# allocations = [
#   <Child Id>,
#   <Present Id>,
#   <Include Present (i.e. allocate the present to this child>,
#   <If the present was excluded>
#   <Were all of these Presents already allocated?>,
#   <Has the Child already been allocated all the Presents they're entitled to?>
# ];
class Allocation:
    def __init__(self,
                 childId,
                 presentId,
                 include,
                 excludePresent,
                 presentAllocationExceeded,
                 childAllocationExceeded):
        self.childId = childId
        self.presentId = presentId
        self.include = include
        self.excludePresent = excludePresent
        self.presentAllocationExceeded = presentAllocationExceeded
        self.childAllocationExceeded = childAllocationExceeded

    def __str__(self):
        output = "ChildId: {childId}, PresentId: {presentId}, Include: {include}, Present Excluded: {excludePresent}, No More Presents: {presentAllocationExceeded}, Child has all Presents: {childAllocationExceeded}"
        return output.format(childId=self.childId,
                             presentId=self.presentId,
                             include=self.include,
                             excludePresent=self.excludePresent,
                             presentAllocationExceeded=self.presentAllocationExceeded,
                             childAllocationExceeded=self.childAllocationExceeded)
