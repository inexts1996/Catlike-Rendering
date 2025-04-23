Shader "Custom/SimplifiedPBR"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Color("tint", Color) = (1,1,1,1)
        _Metallic("Metallic", Range(0,1)) = 0
        _Roughness("Roughness", Range(0.05,1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _Color;
            float _Metallic;
            float _Roughness;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }
            
            float3 fresnelSchlick (float cosTheta, float3 F0)
            {
                return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                
                float3 N = normalize(i.worldNormal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 H = normalize(L + V);
                
                float3 F0 = lerp(float3(0.04, 0.04, 0.04), albedo, _Metallic);
                
                float NdotV = max(dot(N, V), 0.0);
                float3 F = fresnelSchlick(NdotV, F0);
                
                float3 diffuseColor = albedo * (1.0 - _Metallic);
                
                float NdotL = max(dot(N, L), 0.0);
                float3 diffuse = diffuseColor * _LightColor0.rgb * NdotL;
                float3 specular = F * _LightColor0.rgb * NdotL;
                
                return fixed4(diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
}
