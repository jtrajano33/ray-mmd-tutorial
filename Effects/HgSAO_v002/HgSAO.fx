////////////////////////////////////////////////////////////////////////////////////////////////
//
//  HgSAO.fx ver0.0.2  SAO(Scalable Ambient Obscurance)�G�t�F�N�g
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
/*
  Open Source under the "BSD" license: http://www.opensource.org/licenses/bsd-license.php

  Copyright (c) 2011-2012, NVIDIA
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation
     and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

#define UseHDR  0   // HDR�����_�����O�̗L��
// 0 : �ʏ��256�K���ŏ���
// 1 : ���Ɠx�������̂܂܏���

// SAO���s���ۂ̃p�����[�^
float ProjScale <
   string UIName = "SS Scale";
   string UIWidget = "Slider";
   string UIHelp = "AO�ŃT���v�����O���s���ۂ�ScreenSpace�̃X�P�[����";
   bool UIVisible =  true;
   float UIMin = 1.0;
   float UIMax = 1000.0;
> = float( 100.0 );

float Radius <
   string UIName = "AO Disk���a";
   string UIWidget = "Slider";
   string UIHelp = "AO�ŃT���v�����O���s���͈͂�Disk���a";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 3.0 );

float Intensity <
   string UIName = "AO ���x";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.01;
   float UIMax = 2.0;
> = float( 0.5 );

float Bias <
   string UIName = "AO�o�C�A�X";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.001;
   float UIMax = 0.1;
> = float( 0.01 );

int SampCount <
   string UIName = "�T���v����";
   string UIHelp = "AO�ŃT���v�����O���s���ۂ̐�";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 1;
   int UIMax = 30;
> = int( 11 );

// �u���[��������ۂ̃p�����[�^
float BlurPower <
   string UIName = "�u���[���x";
   string UIHelp = "�u���[��������ۂ̃T���v�����O�Ԋu";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 5.0;
> = float( 1.0 );

float OutlineDepth <
   string UIName = "�֊s����[�x";
   string UIHelp = "�ڂ����������ɗ֊s�̓��O�𔻒肷��[�x";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.1 );

float OutlineNormal <
   string UIName = "�֊s����@��";
   string UIHelp = "�ڂ����������ɗ֊s�̓��O�𔻒肷��@��(����)";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.2 );

bool FlagVisibleAO <
   string UIName = "AO�\\��";
   bool UIVisible =  true;
> = false;
//> = true;



// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

// �R���g���[���p�����[�^
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
#ifndef MIKUMIKUMOVING
float3 AcsXYZ  : CONTROLOBJECT < string name = "(self)"; string item = "XYZ"; >;
float3 AcsRxyz : CONTROLOBJECT < string name = "(self)"; string item = "Rxyz"; >;
static float ssScale = max(ProjScale + AcsXYZ.x, 1.0f);
static float Radius1 = max(Radius + AcsXYZ.y, 0.0f);
static float bias = clamp(Bias + AcsXYZ.z, 0.001f, 1.0f);
static float intensity = max(Intensity + degrees(AcsRxyz.x), 0.0f);
static float blurPower = max(BlurPower + degrees(AcsRxyz.z), 0.0f);
#else
static float ssScale = ProjScale;
static float Radius1 = Radius;
static float bias = Bias;
static float intensity = Intensity;
static float blurPower = BlurPower;
#endif

// �X�N���[�����`��͈͂̔{��(��ʉ�SSAO�����̂��ߍL�͈͂�`��)
#define ScrSizeRatio  1.1

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
static float2 SampStep = (float2(blurPower,blurPower)/ViewportSize);

// ��Ɨp�X�N���[���T�C�Y
static float2 WorkViewportSize = float2( floor(ViewportSize*ScrSizeRatio) );
static float2 TrueScnScale = WorkViewportSize / ViewportSize;
static float2 WorkViewportOffset = float2(0.5,0.5) / WorkViewportSize;

// ���W�ϊ��s��
float4x4 ProjMatrix0 : PROJECTION;
static float4x4 ProjMatrix = float4x4( ProjMatrix0[0] / TrueScnScale.x,
                                       ProjMatrix0[1] / TrueScnScale.y,
                                       ProjMatrix0[2],
                                       ProjMatrix0[3] );

// �I�t�X�N���[���@���}�b�v
texture HgSAO_NmlRT: OFFSCREENRENDERTARGET <
    string Description = "HgSAO.fx�̖@���}�b�v";
    float2 ViewPortRatio = {ScrSizeRatio, ScrSizeRatio};
    float4 ClearColor = {0.5, 0.5 ,0, 1};
    float ClearDepth = 1.0;
    string Format = "D3DFMT_A8R8G8B8" ;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;"
        //"MMM_DummyModel = HgSAO_Cancel.fxsub;"
        "* = HgSAO_Normal.fxsub;";
>;
sampler NormalMapSmp = sampler_state {
    texture = <HgSAO_NmlRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �I�t�X�N���[���[�x�}�b�v
texture HgSAO_DepRT: OFFSCREENRENDERTARGET <
    string Description = "HgSAO.fx�̐[�x�}�b�v";
    float2 ViewPortRatio = {ScrSizeRatio, ScrSizeRatio};
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0f;
    string Format = "D3DFMT_R32F";
    int MipLevels = 0;
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "MMM_DummyModel = HgSAO_Cancel.fxsub;"
        "* = HgSAO_Depth.fxsub;"
    ;
>;
sampler DepthMapSmp = sampler_state {
    texture = <HgSAO_DepRT>;
    //Filter = NONE;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,0};
float ClearDepth  = 1.0;

#if UseHDR==0
    #define TEX_FORMAT "D3DFMT_A8R8G8B8"
#else
    #define TEX_FORMAT "D3DFMT_A16B16G16R16F"
    //#define TEX_FORMAT "D3DFMT_A32B32G32R32F"
#endif

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
texture2D ScnMapDepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    string Format = "D3DFMT_D24S8";
>;


// SSAO���̌��ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D SSAO_Tex : RENDERCOLORTARGET <
    float2 ViewPortRatio = {ScrSizeRatio, ScrSizeRatio};
    int MipLevels = 0;
    string Format = "D3DFMT_R16F";
>;
sampler2D SSAOSamp = sampler_state {
    texture = <SSAO_Tex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

// Y�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D SSAO_Tex2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {ScrSizeRatio, ScrSizeRatio};
    int MipLevels = 1;
    string Format = "D3DFMT_R16F";
>;
sampler2D SSAOSamp2 = sampler_state {
    texture = <SSAO_Tex2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {ScrSizeRatio, ScrSizeRatio};
    string Format = "D3DFMT_D24S8";
>;


////////////////////////////////////////////////////////////////////////////////////////////////
// ���ʂ̒��_�V�F�[�_

struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

VS_OUTPUT VS_Common( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    Out.Pos = Pos;
    Out.Tex = Tex + WorkViewportOffset;
    return Out;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// SSAO��

#define DEPTH_FAR  5000.0f  // �[�x�ŉ��l

#define NUM_SPIRAL_TURNS 7  // �T���v�����O��]�p�̃p�����[�^
#define LOG_MAX_OFFSET 3    // �~�b�v�g�p臒l
#define MAX_MIP_LEVEL 5     // �~�b�v���x���ő�l

//���a�̓��
static float Radius2 = Radius1 * Radius1;

// �}�b�v����@���Ɛ[�x���擾
void GetNormalDepth(float2 Tex, out float3 Normal, out float Depth)
{
    // �@��
    float4 ColorN = tex2D( NormalMapSmp, Tex );
    Normal = normalize( ColorN.xyz*2.0f - 1.0f );

    // �[�x
    Depth = tex2Dlod( DepthMapSmp, float4(Tex,0,0) ).r * DEPTH_FAR;
}


// �}�b�v����@���ƃr���[���W���擾
void GetNormalVPos(float2 Tex, out float3 Normal, out float3 VPos)
{
    // �@��,�[�x
    float Depth;
    GetNormalDepth(Tex, Normal, Depth);

    // �r���[���W�ɖ߂�
    float2 PPos = float2(2.0f*Tex.x-1.0f, 1.0f-2.0f*Tex.y);
    VPos = float3(PPos.x / ProjMatrix._11, PPos.y / ProjMatrix._22, 1.0f) * Depth;
}


// �T���v���ʒu��AO�����擾����
//  ssPos:Screen���W(Pixel)  tapIndex:�T���v��Index  VPos:�Ώۍ��W  Normal:�Ώۍ��W�̖@��
//  ssDiskRadius:�f�B�X�N���a  randAng:�����_����]�p�x
float sampleAO(int2 ssPos, int sampIndex, float3 VPos, float3 Normal, float ssDiskRadius, float randAng)
{
    // �T���v�����O�ʒu
    float alpha = float(sampIndex + 0.5f) / SampCount;
    float angle = alpha * (NUM_SPIRAL_TURNS * 6.28) + randAng;
    float ssR = alpha * ssDiskRadius;
    float2 unitOffset = float2(cos(angle), sin(angle)) * ssR;
    float2 texCoord = (float2(ssPos) + unitOffset) / WorkViewportSize;

    // �~�b�v���x��
    int mipLevel = clamp((int)floor(log2(ssR)) - LOG_MAX_OFFSET, 0, MAX_MIP_LEVEL);

    // �I�t�Z�b�g�ʒu�̃r���[���W
    float Depth = tex2Dlod(DepthMapSmp, float4(texCoord, 0, mipLevel)).x * DEPTH_FAR;
    float2 PPos = float2(2.0f*texCoord.x-1.0f, 1.0f-2.0f*texCoord.y);
    float3 offsetVPos = float3(PPos.x / ProjMatrix._11, PPos.y / ProjMatrix._22, 1.0f) * Depth;

    // �T���v�����O�ʒu�x�N�g��(camera space)
    float3 vec = offsetVPos - VPos;

    float vv = dot(vec, vec);
    float vn = dot(vec, Normal);

    // AO�������߂�
    const float epsilon = 0.01f;
    float f = max(Radius2 - vv, 0.0f);
    float ao = f * f * f * max((vn - bias) / (epsilon + vv), 0.0f);

    return ao;
}


// SSAO�}�b�v�쐬
float4 PS_SSAO( float2 Tex: TEXCOORD0 ) : COLOR
{
    // ScreenSpace�̍��W(Pixel)
    int2 ssPos = int2(Tex * WorkViewportSize);

    // HPG12 AlchemyAO�_���Ŏg�p���ꂽ�n�b�V���֐�(XOR���g���Ȃ��̂ŉ���)
    float randAng = (5 * ssPos.x % ssPos.y + ssPos.x * ssPos.y) * 7.0f;

    // �@��,�r���[���W
    float3 Normal, VPos;
    GetNormalVPos( Tex, Normal, VPos);

    // ScreenSpace�ł̃T���v���f�B�X�N���a
    float ssDiskRadius = -ssScale * Radius1 / VPos.z;

    // AO�����v�Z
    float sum = 0.0f;
    for (int i = 0; i < SampCount; i++) {
         sum += sampleAO(ssPos, i, VPos, Normal, ssDiskRadius, randAng);
    }

    float temp = Radius2 * Radius1;
    sum /= temp * temp;
    float ao = max(0.0f, 1.0f - sum * intensity * (5.0f / SampCount));

    // Bilateral box-filter over a quad for free, respecting depth edges
    // (the difference that this makes is subtle)
    if (abs(ddx(VPos.z)) < 0.02f) {
        ao -= ddx(ao) * ((ssPos.x % 2) - 0.5f);
    }
    if (abs(ddy(VPos.z)) < 0.02f) {
        ao -= ddy(ao) * ((ssPos.y % 2) - 0.5f);
    }

    return float4(1.0f-ao, 0, 0, 1);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// SSAO�}�b�v�̂ڂ���

// �ڂ��������̏d�݌W���F
//    �K�E�X�֐� exp( -x^2/(2*d^2) ) �� d=5, x=0�`7 �ɂ��Čv�Z�����̂��A
//    (WT_7 + WT_6 + �c + WT_1 + WT_0 + WT_1 + �c + WT_7) �� 1 �ɂȂ�悤�ɐ��K����������
float WT_COEF[8] = { 0.0920246,
                     0.0902024,
                     0.0849494,
                     0.0768654,
                     0.0668236,
                     0.0558158,
                     0.0447932,
                     0.0345379 };

// �T���v�����O����~�b�v�}�b�v���x��
static float MipLv = log2( max(ViewportSize.x*SampStep.x, 1.0f) );

// �ڂ����T���v�����O�͈͂̋��E����
bool IsSameArea(float Depth0, float Depth, float3 Normal0, float3 Normal)
{
    float edgeDepthThreshold = min(OutlineDepth + 0.05f * max(Depth0-20.0f, 0.0f), 7.0f);
    return (abs(Depth0 - Depth) < edgeDepthThreshold && abs(Normal0 - Normal) < OutlineNormal);
}

// �K�E�X�t�B���^�[�ɂ��ڂ���
float SSAOGaussianXY(float2 Tex, sampler2D Samp, float2 smpVec, bool isMipMap)
{
    float mipLv = isMipMap ? MipLv : 0.0f;
    float3 Normal0, Normal;
    float Depth0, Depth;
    GetNormalDepth(Tex, Normal0, Depth0);

    float ssao = tex2Dlod( Samp, float4(Tex,0,mipLv) ).r;
    float sumSSAO = WT_COEF[0] * ssao;
    float sumRate = WT_COEF[0];

    // ���E�̔��Α��ɂ���F�̓T���v�����O���Ȃ�
    [unroll]
    for(int i=1; i<8; i++){
        float2 Tex1 = Tex - smpVec * SampStep * i;
        GetNormalDepth(Tex1, Normal, Depth);
        if( IsSameArea(Depth0, Depth, Normal0, Normal) ){
            ssao = tex2Dlod( Samp, float4(Tex1,0,mipLv) ).r;
            sumSSAO += WT_COEF[i] * ssao;
            sumRate += WT_COEF[i];
        }

        Tex1 = Tex + smpVec * SampStep * i;
        GetNormalDepth(Tex1, Normal, Depth);
        if( IsSameArea(Depth0, Depth, Normal0, Normal) ){
            ssao = tex2Dlod( Samp, float4(Tex1,0,mipLv) ).r;
            sumSSAO += WT_COEF[i] * ssao;
            sumRate += WT_COEF[i];
        }
    }

    return (sumSSAO / sumRate);
}

// Y����
float4 PS_SSAOGaussianY( float2 Tex: TEXCOORD0 ) : COLOR
{
    float ssao = SSAOGaussianXY( Tex, SSAOSamp, float2(0,1), true );
    return float4(ssao, 0, 0, 1);
}

// X����
float4 PS_SSAOGaussianX( float2 Tex: TEXCOORD0 ) : COLOR
{
    float ssao = SSAOGaussianXY( Tex, SSAOSamp2, float2(1,0), false );
    return float4(ssao, 0, 0, 1);
}


////////////////////////////////////////////////////////////////////////////////////////////////

// RGB����YCbCr�ւ̕ϊ�
void RGBtoYCbCr(float3 rgbColor, out float Y, out float Cb, out float Cr)
{
    Y  =  0.298912f * rgbColor.r + 0.586611f * rgbColor.g + 0.114478f * rgbColor.b;
    Cb = -0.168736f * rgbColor.r - 0.331264f * rgbColor.g + 0.5f      * rgbColor.b;
    Cr =  0.5f      * rgbColor.r - 0.418688f * rgbColor.g - 0.081312f * rgbColor.b;
}


// YCbCr����RGB�ւ̕ϊ�
float3 YCbCrtoRGB(float Y, float Cb, float Cr)
{
    float R = Y - 0.000982f * Cb + 1.401845f * Cr;
    float G = Y - 0.345117f * Cb - 0.714291f * Cr;
    float B = Y + 1.771019f * Cb - 0.000154f * Cr;
    return float3( R, G, B );
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �X�N���[���o�b�t�@�̍���

VS_OUTPUT VS_MixScreen( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    return Out;
}

float4 PS_MixScreen( float2 Tex: TEXCOORD0 ) : COLOR
{
    // SSAO�̃}�b�v���W�ɏC��
    float2 offset = float2(1.0f - 1.0f/TrueScnScale.x, 1.0f - 1.0f/TrueScnScale.y) * 0.5f;
    float2 Tex0 = Tex / TrueScnScale + offset;

    float ssao = tex2D( SSAOSamp, Tex0 ).r;

    // �֊s���̃W���M�[���Ȃ��܂���
    float2 SmpStep = float2(1,1)/WorkViewportSize;
    ssao += ssao;
    ssao += tex2D( SSAOSamp, Tex0+SmpStep*float2( 0,-1) ).r;
    ssao += tex2D( SSAOSamp, Tex0+SmpStep*float2( 0, 1) ).r;
    ssao += tex2D( SSAOSamp, Tex0+SmpStep*float2(-1, 0) ).r;
    ssao += tex2D( SSAOSamp, Tex0+SmpStep*float2( 1, 0) ).r;
    ssao += tex2D( SSAOSamp, Tex0+SmpStep*float2(-1,-1) ).r;
    ssao += tex2D( SSAOSamp, Tex0+SmpStep*float2( 1,-1) ).r;
    ssao += tex2D( SSAOSamp, Tex0+SmpStep*float2(-1, 1) ).r;
    ssao += tex2D( SSAOSamp, Tex0+SmpStep*float2( 1, 1) ).r;
    ssao *= 0.1f;

    // ���摜�̐F
    float4 Color = tex2D( ScnSamp, Tex );

    // RGB����YCbCr�ւ̕ϊ�
    float Y, Cb, Cr;
    RGBtoYCbCr( Color.rgb, Y, Cb, Cr);

    // ����
    float a = clamp(1.0f - 0.05f * AcsSi * ssao, 0.1f, 1.0f);
    float density = 1.0f / a;
    float3 color = lerp(Color.rgb*a, Color.rgb, pow(Color.rgb, density));
    Color.rgb = lerp( YCbCrtoRGB( Y*a, Cb, Cr), color, AcsTr);

    if( FlagVisibleAO ) {
        // AO�\��
        Color = float4(1-ssao, 1-ssao, 1-ssao, 1);
    }

    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTech <
    string Script = 
        // �I���W�i���̕`��
        "RenderColorTarget0=ScnMap;"
            "RenderDepthStencilTarget=ScnMapDepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "ScriptExternal=Color;"
        // SSAO����
        "RenderColorTarget0=SSAO_Tex;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=SSAODraw;"

        // SSAO�}�b�v�̂ڂ���Y����
        "RenderColorTarget0=SSAO_Tex2;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=SSAOGaussianY;"
        // SSAO�}�b�v�̂ڂ���X����
        "RenderColorTarget0=SSAO_Tex;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=SSAOGaussianX;"

        // �`�挋�ʏ����o��
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "Pass=MixPass;"
    ;
> {
    pass SSAODraw < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_SSAO();
    }
    pass SSAOGaussianY < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_SSAOGaussianY();
    }
    pass SSAOGaussianX < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_SSAOGaussianX();
    }
    pass MixPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_MixScreen();
        PixelShader  = compile ps_3_0 PS_MixScreen();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
