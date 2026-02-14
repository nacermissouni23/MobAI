import numpy as np
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor

class HurdleModel:
    """
    Modèle en deux étapes :
      - classifieur pour prédire si demande > 0
      - régresseur pour prédire la quantité quand demande > 0
    """
    def __init__(self, clf_params=None, reg_params=None):
        self.clf = RandomForestClassifier(n_estimators=200, max_depth=10,
                                          random_state=42, n_jobs=-1)
        self.reg = RandomForestRegressor(n_estimators=200, max_depth=10,
                                         random_state=42, n_jobs=-1)

    def fit(self, X, y):
        pos_mask = y > 0
        X_pos = X[pos_mask]
        y_pos = y[pos_mask]

        self.clf.fit(X, (y > 0).astype(int))
        if len(X_pos) > 0:
            self.reg.fit(X_pos, y_pos)
        return self

    def predict(self, X):
        pred_bin = self.clf.predict(X)
        pred_quant = self.reg.predict(X)
        pred_quant[pred_bin == 0] = 0
        return pred_quant