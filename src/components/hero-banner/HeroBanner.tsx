interface Props {
    message: string
}

function HeroBanner(props: Props) {
    return(
        <>
            <div className="container bg-green-500 mt-10 p-20 shadow-2xl rounded-md mx-auto my-auto">
                <h1 className="font-extrabold text-white text-center text-lg">
                    {props.message}
                </h1>
            </div>
        </>
    )
}

export default HeroBanner;