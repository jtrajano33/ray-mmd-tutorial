HgSAO.fx ver0.0.2

SAO(Scalable Ambient Obscurance)�G�t�F�N�g�ł��B
SAO��SSAO�̔��W�`�ԂŁA�ׂ������ʂɑ΂��Ă���r�I�Y���AO���悹�邱�Ƃ��o���܂��B
mogg����ScalableAO_MMM�T���v���A�y�ъJ����(NVIDIA)�̃T���v���R�[�h���Q�l��MMD/MMM��
���p�I�Ɏg����悤�ɉ��ǂ��Ă݂܂����B


�E�����
SM3.0�Ή��O���t�B�b�N�{�[�h���K�{�ɂȂ�܂��B
MMEv0.37, MMEv0.37x64�CMMMv125a�CMMM64v125a�œ���m�F���s���Ă��܂��B���o�[�W�����ł͓��삵�Ȃ��\��������܂��B


�E�g�p���@(MME)
(1)HgSAO.x��MMD�Ƀ��[�h���Ă��������B
(2)HgSAO.fx�̐擪�p�����[�^��K�X�ύX���Ă��������B
(3)MMD�̃A�N�Z�T���p�����[�^�ňȉ��̕ύX���\�ł��B
    X  : AO������ScreenSpace�X�P�[����(-100�`+1000���x�Œ���)
    Y  : AO������Disk���a(-3�`+10���x�Œ���)
    Z  : AO�����̃o�C�A�X�l(-0.1�`+0.1���x�Œ���)
    Rx : AO���x(-0.5�`+2.0���x�Œ���)
    Rz : AO�̂ڂ������x(-1�`+3���x�Œ���)
    Si : AO�ɂ��A�̔Z�x����(0�`2���x�Œ���)
    Tr : ����������ƉA�̍������@�� ���ȏ�Z����Z �ɕω����܂��B


�EAO�L�����Z���ɂ���
�MMEffect�����G�t�F�N�g�������HgSAO_DepRT�^�u��胂�f����I������HgSAO_Cancel.fxsub��K�p����ƁA
�Ӑ}�I�Ɏw�肵�����f������AO���������邱�Ƃ��o���܂��B
(Lat�����f�����g�p����ꍇ��,���̕��@�Ńt�F�C�X����AO�������s���Ă�������)


�EMikuMikuMoving�ɂ���
���̃G�t�F�N�g��MikuMikuMoving�ɂ��Ή����Ă��܂��B
HgSAO.fx�𒼐�MikuMikuMoving�Ƀ��[�h���Ă����p�������B
MMM�ł�HgSAO.fx�̃G�t�F�N�g�v���p�e�B�ɒǉ�����UI�R���g���[�����p�����[�^�ύX���\�ł��B
(�G�t�F�N�g�v���p�e�B�̢�g��,��A���t�@���MME��Si,Tr�Ɠ��������ł�)


�E�Z�p���
�J�����T�C�g�Fhttps://research.nvidia.com/publication/scalable-ambient-obscurance
mogg���Љ�L���Fhttp://ch.nicovideo.jp/mogg/blomaga/ar568279


�E�X�V����
v0.0.2  2015/10/31 MMD�̃t���X�N���[���\���Ő���ɕ`�悳��Ȃ��Ȃ�s��̏C��
                   ���̃|�X�g�G�t�F�N�g���p���ɐ���ɕ`�悳��Ȃ��Ȃ�s��̏C��
v0.0.1  2014/7/25  ����Ō��J


�E�Ɛӎ���
�����p�E���ρE�񎟔z�z�͎��R�ɂ���Ă��������Ă��܂��܂���B�A�����s�v�ł��B
�����������̍s�ׂ͑S�Ď��ȐӔC�ł���Ă��������B
���̃v���O�����g�p�ɂ��A�����Ȃ鑹�Q���������ꍇ�ł������͈�؂̐ӔC�𕉂��܂���B

���{�v���O������BSD���C�Z���X�Ƃ��܂�(���̃\�[�X�R�[�h�������Ȃ̂�)�B
  �Ĕz�z�̍ۂɃv���O�������ɂ�������͍폜���Ȃ��ł��������B


by �j��P
Twitter : @HariganeP


