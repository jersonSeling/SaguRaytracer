unit uSceneElements;

interface

uses
  uVectorTypes;

type

  TLight = class
  public
    Position: TVector3f;
    Intensity: Single;
  end;

  { TMaterial }

  TMaterial = class
  public
    Name: string;
    DiffuseColor: TVector3f;
    Albedo: TVector4f;
    SpecularExponent: Single;
    RefractiveIndex: Single;
    constructor Create(const _AName: string);
    function CalculateDiffuseColorInScene(const _ADiffuseLightIntensity: Single): TVector3f;
    function CalculateSpecularColorInScene(const _ASpecularLightIntensity: Single): TVector3f;
    function CalculateReflectColorInScene(const _AReflectColor: PVector3f): TVector3f;
    function CalculateRefractColorInScene(const _ARefractColor: PVector3f): TVector3f;
  end;

  TMeshObject = class
  public
    Center: TVector3f;
    Material: TMaterial;

    function RayIntersect(_AOrig, _ADir: TVector3f; out _At0: Single): Boolean; virtual; abstract;
  end;

  TSphere = class(TMeshObject)
  public
    Radius: Single;
    function RayIntersect(_AOrig, _ADir: TVector3f; out _At0: Single): Boolean; override;
  end;

  TCamera = class
  public
    Position: TVector3f;
    Direction: PVector3f;
    FOV: Single;
    Width: Integer;
    Height: Integer;
    BackgroundColor: PVector3f;
  end;

implementation

{ TSphere }

function TSphere.RayIntersect(_AOrig, _ADir: TVector3f; out _At0: Single): Boolean;
var
  AL: TVector3f;
  Atca: Single;
  Ad2: Single;
  Athc: Single;
  At1: Single;
begin

  //writeln(_AOrig.PrettyString + ' - ' +_ADir.PrettyString);


  AL := Center.Clone();
  AL.Subtract(@_AOrig);

  Atca := AL.DotProduct(@_ADir);
  Ad2 := AL.DotProduct(@AL) - (Atca * Atca);

  if (Ad2 > Radius * Radius) then
  begin
  //writeln('no intersect');
    Result := False;
    exit;
  end;

  Athc := Sqrt(Radius * Radius - Ad2);
  _At0 := Atca - Athc;
  At1 := Atca + Athc;

  if (_At0 < 0) then
    _At0 := At1;

  if (_At0 < 0) then
  begin
    //writeln('no intersect');
    Result := False;
    exit;
  end;

  //writeln('intersect');
  Result := True;
end;

{ TMaterial }

function TMaterial.CalculateDiffuseColorInScene(const _ADiffuseLightIntensity: Single): TVector3f;
begin
  Result := Self.DiffuseColor.Clone();
  Result.Scale(_ADiffuseLightIntensity * Self.Albedo.X)
end;

function TMaterial.CalculateReflectColorInScene(const _AReflectColor: PVector3f): TVector3f;
begin
  Result := _AReflectColor.Clone();
  Result.Scale(Self.Albedo.Z);
end;

function TMaterial.CalculateRefractColorInScene(const _ARefractColor: PVector3f): TVector3f;
begin
  Result := _ARefractColor.Clone();
  Result.Scale(Self.Albedo.W);
end;

function TMaterial.CalculateSpecularColorInScene(const _ASpecularLightIntensity: Single): TVector3f;
var
  ASpecularFactor: Single;
begin
  ASpecularFactor := _ASpecularLightIntensity * Self.Albedo.Y;

  Result.Init(ASpecularFactor, ASpecularFactor, ASpecularFactor);
end;

constructor TMaterial.Create(const _AName: string);
begin
  DiffuseColor.Init(0.0, 0.0, 0.0);
  Albedo.Init(1, 0, 0, 0);
  SpecularExponent := 50;
  RefractiveIndex := 1;

  Name := _AName;
end;

end.
