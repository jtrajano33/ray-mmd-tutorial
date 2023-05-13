#define VOLUMETRIC_FOG_ENABLE 1
#define VOLUMETRIC_FOG_MAP_QUALITY 0
#define VOLUMETRIC_FOG_SAMPLES_LENGTH 48
#define VOLUMETRIC_FOG_ANISOTROPY 1

#define LIGHT_PARAMS_FILE "IES.HDR"

static const float3 FogRangeParams = float3(100.0, 0.0, 200.0);
static const float3 FogAttenuationBulbParams = float3(1.0, 0.0, 5.0);
static const float3 FogIntensityParams = float3(1.0, 0.0, 20.0);
static const float3 FogMieParams = float3(0.76, 0.01, 0.999);
static const float3 FogDensityParams = float3(0.025, 0.001, 0.25);

#include "../ies_fog.fxsub"