// Crest Ocean System

// This file is subject to the MIT License as seen in the root of this folder structure (LICENSE)

namespace Crest
{
    using System.Collections.Generic;
    using UnityEngine;

    [AddComponentMenu(Internal.Constants.MENU_PREFIX_SCRIPTS + "Apply Underwater Fog To Transparent")]
    public class ApplyUnderwaterFogToTransparent : MonoBehaviour
    {
        [Tooltip("If enabled, the depth fog will be correctly blended with the object's color at the performance cost of an extra texture copy/blit.")]
        [SerializeField]
        internal bool _highQuality;
        public static readonly List<ApplyUnderwaterFogToTransparent> s_Renderers = new List<ApplyUnderwaterFogToTransparent>();
        internal Renderer _renderer;

        [Tooltip("The shader pass to use when rendering this object.")]
        [SerializeField]
        internal int _shaderPass;

        void OnEnable()
        {
            if (TryGetComponent(out _renderer) && !s_Renderers.Contains(this))
            {
                // If the shader has other passes (like shadows) then this will stop them from working.
                _renderer.enabled = false;
                s_Renderers.Add(this);
            }
        }

        void LateUpdate()
        {
            // Quick and dirty optimisation.
            var maxWaterHeight = OceanRenderer.Instance.SeaLevel + OceanRenderer.Instance.MaxVertDisplacement;
            // TODO: Throws exceptions when renderer is disabled for ParticleSystem.
            // TODO: Probably a better to check this.
            _renderer.enabled = _renderer.bounds.ClosestPoint(transform.position + Vector3.down * 10000f).y > maxWaterHeight;
        }

        void OnDisable()
        {
            if (_renderer != null && s_Renderers.Contains(this))
            {
                _renderer.enabled = true;
                s_Renderers.Remove(this);
            }
        }
    }
}
