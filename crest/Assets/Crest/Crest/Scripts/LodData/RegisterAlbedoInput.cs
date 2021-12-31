﻿// Crest Ocean System

// This file is subject to the MIT License as seen in the root of this folder structure (LICENSE)

using UnityEngine;

namespace Crest
{
    /// <summary>
    /// Registers a custom input to the albedo data. Attach this GameObjects that you want to influence the surface colour.
    /// </summary>
    [ExecuteAlways]
    [AddComponentMenu(MENU_PREFIX + "Albedo Input")]
    [HelpURL(Internal.Constants.HELP_URL_BASE_USER + "ocean-simulation.html" + Internal.Constants.HELP_URL_RP + "#albedo")]
    public class RegisterAlbedoInput : RegisterLodDataInputWithSplineSupport<LodDataMgrAlbedo, SplinePointDataFlow> // TODO
    {
        /// <summary>
        /// The version of this asset. Can be used to migrate across versions. This value should
        /// only be changed when the editor upgrades the version.
        /// </summary>
        [SerializeField, HideInInspector]
#pragma warning disable 414
        int _version = 0;
#pragma warning restore 414

        public override bool Enabled => true;

        public override float Wavelength => 0f;

        protected override Color GizmoColor => new Color(0f, 0f, 1f, 0.5f);

        protected override string ShaderPrefix => string.Empty;

        protected override bool FollowHorizontalMotion => _followHorizontalMotion;

        protected override string SplineShaderName => "Hidden/Crest/Inputs/Albedo/Spline Geometry";
        protected override Vector2 DefaultCustomData => new Vector2(SplinePointDataFlow.k_defaultSpeed, 0f); // TODO

        [Header("Other Settings")]

        [SerializeField, Tooltip(k_displacementCorrectionTooltip)]
        bool _followHorizontalMotion = false;

#if UNITY_EDITOR
        protected override string FeatureToggleName => "_createAlbedoSim";
        protected override string FeatureToggleLabel => "Create Albedo Sim";
        protected override bool FeatureEnabled(OceanRenderer ocean) => ocean.CreateAlbedoData;

        //protected override string RequiredShaderKeywordProperty => LodDataMgrAlbedo.MATERIAL_KEYWORD_PROPERTY;
        //protected override string RequiredShaderKeyword => LodDataMgrAlbedo.MATERIAL_KEYWORD;

        //protected override string MaterialFeatureDisabledError => LodDataMgrAlbedo.ERROR_MATERIAL_KEYWORD_MISSING;
        //protected override string MaterialFeatureDisabledFix => LodDataMgrAlbedo.ERROR_MATERIAL_KEYWORD_MISSING_FIX;
#endif // UNITY_EDITOR
    }
}