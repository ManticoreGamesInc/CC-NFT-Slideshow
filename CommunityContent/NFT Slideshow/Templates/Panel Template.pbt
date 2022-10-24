Assets {
  Id: 6940651557781926888
  Name: "Panel Template"
  PlatformAssetType: 5
  TemplateAsset {
    ObjectBlock {
      RootId: 7125743199249511102
      Objects {
        Id: 7125743199249511102
        Name: "World Image Panel"
        Transform {
          Scale {
            X: 10.7066965
            Y: 10.7066965
            Z: 10.7066965
          }
        }
        ParentId: 7797979240375183525
        UnregisteredParameters {
          Overrides {
            Name: "cs:PanelOffset"
            Float: 0
          }
          Overrides {
            Name: "cs:ImageSize"
            Int: 800
          }
          Overrides {
            Name: "cs:ImageOffset"
            Float: 0
          }
          Overrides {
            Name: "cs:ScrollSpeed"
            Float: 0
          }
        }
        Collidable_v2 {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        Visible_v2 {
          Value: "mc:evisibilitysetting:inheritfromparent"
        }
        CameraCollidable {
          Value: "mc:ecollisionsetting:inheritfromparent"
        }
        EditorIndicatorVisibility {
          Value: "mc:eindicatorvisibility:visiblewhenselected"
        }
        Control {
          Width: 800
          Height: 800
          RenderTransformPivot {
            Anchor {
              Value: "mc:euianchor:middlecenter"
            }
          }
          Panel {
            Opacity: 1
            OpacityMaskBrush {
            }
          }
          AnchorLayout {
            SelfAnchor {
              Anchor {
                Value: "mc:euianchor:topleft"
              }
            }
            TargetAnchor {
              Anchor {
                Value: "mc:euianchor:topleft"
              }
            }
          }
        }
        IsReplicationEnabledByDefault: true
      }
    }
    PrimaryAssetId {
      AssetType: "None"
      AssetId: "None"
    }
  }
  SerializationVersion: 119
}
