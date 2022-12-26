def str_to_felt(text):
    b_text = bytes(text, "ascii")
    return int.from_bytes(b_text, "big")

def to_uint(a):
    """Takes in value, returns uint256-ish tuple."""
    return (a & ((1 << 128) - 1), a >> 128)

def long_str_to_array(text):
    res = []
    for tok in text:
        res.append(str_to_felt(tok))
    return res

def long_str_to_print_array(text):
    res = []
    for tok in text:
        res.append(str_to_felt(tok))
    return ' '.join(res)

def decimal_to_hex(decimal: int):
    return hex(decimal)


## VARIOUS
SALT = 0


## CONTRACTS SOURCE CODE 
ERC20_SOURCE_CODE = "../../lib/openzeppelin/token/erc20/presets/ERC20Mintable.cairo"
FAUCET_SOURCE_CODE ="../../lib/utils/faucet.cairo"
DP_SOURCE_CODE="../../lib/morphine/utils/dataProvider.cairo"
ERC4626_SOURCE_CODE = "../../tests/mocks/erc4626.cairo"
EMPIRIC_ORACLE_SOURCE_CODE = "../../tests/mocks/empiricOracle.cairo"
DRIP_SOURCE_CODE="../../lib/morphine/drip/drip.cairo"
ERC4626_PRICE_FEED_SOURCE_CODE = "../../lib/morphine/oracle/derivativePriceFeed/erc4626.cairo"
REGISTERY_SOURCE_CODE = "../../lib/morphine/registery.cairo"
DRIP_FACTORY_SOURCE_CODE = "../../lib/morphine/drip/dripFactory.cairo"
ORACLE_TRANSIT_SOURCE_CODE = "../../lib/morphine/oracle/oracleTransit.cairo"
INTEREST_RATE_MODEL_SOURCE_CODE = "../../lib/morphine/pool/linearInterestRateModel.cairo"
POOL_SOURCE_CODE = "../../lib/morphine/pool/pool.cairo"
PASS_SOURCE_CODE = "../../lib/morphine/token/morphinePass.cairo"
MINTER_SOUCRE_CODE = "../../lib/morphine/token/minter.cairo"
DRIP_MANAGER_SOURCE_CODE = "../../lib/morphine/drip/dripManager.cairo"
DRIP_TRANSIT_SOURCE_CODE = "../../lib/morphine/drip/dripTransit.cairo"
DRIP_CONFIGURATOR_SOURCE_CODE = "../../lib/morphine/drip/dripConfigurator.cairo"
DRIP_INFRA_FACTORY_SOURCE_CODE = "../../lib/morphine/deployment/dripInfraFactory.cairo"


## HASH
ERC20_HASH=1515369715480586678371871707714455491518866650338056761811368589140008332440
FAUCET_HASH=1647980243453739192790302298162846929224199636665047613293689882696401554566
DP_HASH=897529167609358564973390357337304819431017698960487489455257773605961710125 
EMPIRIC_HASH = 5755831660708856892810427071180638230886885985735079627958382952945798945
ERC4626_HASH = 3177736643056838684957359654467894140894092331386636448138632244448481031098
ERC4626_PRICE_FEED_HASH = 3456996936454517072155935217253182389372587970966916468873658483681202499880
DRIP_HASH = 3470768313806998412707504545215648081657424043867684497421112488270557126616
REGISTERY_HASH = 1288233144853942835256639887824459106824078942442917350611588728975210655140
DRIP_FACTORY_HASH = 3212209140101738968637559516396157847660880131085211319939476192782848287622
ORACLE_TRANSIT_HASH = 1102954667229741963948847799486493325283950793995721023205953120841037500137
INTEREST_RATE_MODEL_HASH = 1082642635321285981211985190038968243353495468799428202225732642323319566301 
POOL_HASH = 2551798542481764029712770531281521043988962942523847289399020245777609716532
PASS_HASH = 2744136250761647907164842210516320389257880931934296969723808192508631850932
MINTER_HASH = 3159477990592986063584843404364937079934054404976668811946558272579923331834
DRIP_MANAGER_HASH = 2194412820477415112405360811727033849775363418828287744877673970827367968802
DRIP_TRANSIT_HASH = 1984897992424668400754724608444190160741791986582259779272428534766849769813
DRIP_CONFIGURATOR_HASH = 2526551841242027061131073943125144926907977707661880719642755678571534037758
DRIP_INFRA_FACTORY_HASH = 2121694535637984971339249181858534954815246748606457691288309749522059058348



## CONTRACTS ABI
ERC20_ABI = "../../build/erc20_abi.json"
FAUCET_ABI ="../../build/faucet_abi.json"
ERC4626_ABI ="../../build/erc4626_abi.json"
ORACLE_TRANSIT_ABI = "../../build/oracle_transit_abi.json"
REGISTERY_ABI = "../../build/registery_abi.json"
DRIP_FACTORY_ABI = "../../build/drip_factory_abi.json"
INTEREST_RATE_MODEL_ABI= "../../build/interest_rate_model_abi.json"
POOL_ABI= "../../build/pool_abi.json"
PASS_ABI= "../../build/pass_abi.json"
MINTER_ABI = "../../build/minter_abi.json"
DRIP_MANAGER_ABI = "../../build/drip_manager_abi.json"
DRIP_CONFIGURATOR_ABI = "../../build/drip_configurator_abi.json"
DRIP_TRANSIT_ABI = "../../build/drip_transit_abi.json"
DRIP_INFRA_FACTORY_ABI = "../../build/drip_infra_factory_abi.json"






## CONTRACT ADDRESSES TOKEN
MDAI_TOKEN = 1343736755528245583556844068241376787306736200839213048599512351803845737954
MDAI_FAUCET = 2782075477786179006318107668768994745145980650246910991540991004842130432355
METH_TOKEN = 2531763062148050252631886495495305907867811931278673729671486857820654632373
METH_FAUCET = 3437507200985476270270551084396656880648881838932408415183233498621812412964
MBTC_TOKEN = 2096993072405431496993619226094040984122887043386895058723661901970846736977
MBTC_FAUCET = 593505181486266252306643196819483660726592067875097630285628128943095332613 
VMETH = 3446502081995786345634146805122248791347638340202520965030638671516998580902

## CONTRACT ADDRESSES
ETH = 2087021424722619777119509474943472645767659996348769578120564519014510906823
UD = "0x041a78e741e5af2fec34b695679bc6891742439f7afb8484ecd7766661ad02bf"

## CONTRACT ADDRESSES MORPHINE 
DP = 1733307589105524423786206830283152008207743537665557959094373698446000640539 
EMPIRIC = 3192999979809713360859433670175671629845112645681593563478436841098137933103
ERC4626_PRICE_FEED = 2047635248313878453958284951015662486494385192215501297325413794656612859354
MORPHINE_TREASURY = 1063295380747518586658370424749994928222764270094741700145566703757650981707
REGISTERY = 518186857286480997042134318740742945484555217897153472954903189151185344668
DRIP_FACTORY = 329371139683704594979494494179676512830734507737315551474196441869549755171
ORACLE_TRANSIT = 2240990798020187506540983177006033876777311404260591869591592097798926375786

## POOL DAI
INTEREST_RATE_MODEL_POOL_DAI = 2948141202106033005214281151204584472323771584330841193680690285562088533420 
POOL_DAI = 3574945653108117175972689729365072538164480081933340458286113719037561000111 

##INFRA DAI
# PASS = 2628615181116646187837402385397341849360191406243650485142439444939160485307
# MINTER = 1816447656657949598002116020174159433664002803952463624078987166270116122832
# DRIP_INFRA_FACTORY = 1045167353116554844625222277130971298420575927317596467442432777342723857206
# METH_TOKEN_LT_POOL_DAI = 85000000000000000
# VMETH_TOKEN_LT_POOL_DAI = 80000000000000000

## POOL ETH
INTEREST_RATE_MODEL_POOL_ETH = 1951753492321111163010985174472073754860688724619294676609251018017892721540  
POOL_ETH = 3089330706614142961024103776014966234834155614137320779880688978289459519250  

## POOL BTC
INTEREST_RATE_MODEL_POOL_BTC = 1376371524046000777847251838305370708641222742139629012784683369991847622212    
POOL_BTC = 35788003305711806183105639616479435864048828587361253702731992789601754637    


## TOKEN KEYS
ETH_USD = 19514442401534788
BTC_USD = 18669995996566340
DAI_USD = 28254602066752356

## TOKEN PRICE
ETH_PRICE = 100000000000
BTC_PRICE = 2000000000000
DAI_PRICE = 100000000
